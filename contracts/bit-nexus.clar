;; Title: BitNexus Gaming Protocol
;; Summary: A comprehensive Web3 gaming ecosystem built on Stacks for Bitcoin L2
;;
;; Description: BitNexus is a next-generation blockchain gaming protocol that 
;; revolutionizes digital asset ownership through Bitcoin's security and Stacks' 
;; smart contract capabilities. The protocol features:
;;
;; - Dynamic NFT game assets with evolving stats and cross-world compatibility
;; - Avatar progression system with experience-based leveling mechanics  
;; - Multi-world gaming environments with customizable entry requirements
;; - Competitive leaderboards with Bitcoin-backed reward distribution
;; - Decentralized asset trading and ownership verification
;; - Admin-controlled protocol governance with fee management
;;
;; Built for scalability, security, and seamless user experience on Bitcoin L2.
;; Perfect for GameFi applications, metaverse projects, and blockchain gaming.

;; ERROR CONSTANTS

;; Authorization & Access Control Errors
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-OWNER (err u21))

;; Asset & Avatar Management Errors  
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INVALID-AVATAR (err u13))
(define-constant ERR-INVALID-NAME (err u15))
(define-constant ERR-INVALID-DESCRIPTION (err u16))
(define-constant ERR-INVALID-RARITY (err u17))
(define-constant ERR-INVALID-POWER-LEVEL (err u18))
(define-constant ERR-INVALID-ATTRIBUTES (err u19))

;; Financial & Transfer Errors
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-FEE (err u10))

;; Game Mechanics Errors
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-LEVEL-UP (err u24))
(define-constant ERR-MAX-LEVEL-REACHED (err u22))
(define-constant ERR-MAX-EXPERIENCE-REACHED (err u23))

;; World & Registration Errors
(define-constant ERR-WORLD-NOT-FOUND (err u14))
(define-constant ERR-INVALID-WORLD-ACCESS (err u20))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))

;; Leaderboard & Input Validation Errors
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-INVALID-INPUT (err u8))

;; GAME MECHANICS CONSTANTS

(define-constant MAX-LEVEL u100)
(define-constant MAX-EXPERIENCE-PER-LEVEL u1000)
(define-constant BASE-EXPERIENCE-REQUIRED u100)

;; PROTOCOL CONFIGURATION VARIABLES

(define-data-var protocol-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)
(define-data-var total-assets uint u0)
(define-data-var total-avatars uint u0)
(define-data-var total-worlds uint u0)

;; ACCESS CONTROL MAPS

(define-map protocol-admin-whitelist
  principal
  bool
)

;; NFT DEFINITIONS

(define-non-fungible-token nexus-asset uint)
(define-non-fungible-token nexus-avatar uint)

;; DATA STRUCTURE DEFINITIONS

;; Asset Metadata Storage
(define-map nexus-asset-metadata
  { token-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint,
    world-id: uint,
    attributes: (list 10 (string-ascii 20)),
    experience: uint,
    level: uint,
  }
)

;; Avatar System Storage
(define-map avatar-metadata
  { avatar-id: uint }
  {
    name: (string-ascii 50),
    level: uint,
    experience: uint,
    achievements: (list 20 (string-ascii 50)),
    equipped-assets: (list 5 uint),
    world-access: (list 10 uint),
  }
)

;; Virtual Worlds Registry
(define-map game-worlds
  { world-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    entry-requirement: uint,
    active-players: uint,
    total-rewards: uint,
  }
)

;; Competitive Leaderboard System
(define-map leaderboard
  { player: principal }
  {
    score: uint,
    games-played: uint,
    total-rewards: uint,
    avatar-id: uint,
    rank: uint,
    achievements: (list 20 (string-ascii 50)),
  }
)

;; VALIDATION FUNCTIONS

(define-private (is-valid-name (name (string-ascii 50)))
  (and
    (>= (len name) u1)
    (<= (len name) u50)
    (not (is-eq name ""))
  )
)

(define-private (is-valid-description (description (string-ascii 200)))
  (and
    (>= (len description) u1)
    (<= (len description) u200)
    (not (is-eq description ""))
  )
)

(define-private (is-valid-rarity (rarity (string-ascii 20)))
  (or
    (is-eq rarity "common")
    (is-eq rarity "uncommon")
    (is-eq rarity "rare")
    (is-eq rarity "epic")
    (is-eq rarity "legendary")
  )
)

(define-private (is-valid-power-level (power uint))
  (and (>= power u1) (<= power u1000))
)

(define-private (is-valid-attributes (attributes (list 10 (string-ascii 20))))
  (and
    (>= (len attributes) u1)
    (<= (len attributes) u10)
  )
)

(define-private (is-valid-world-access (worlds (list 10 uint)))
  (and
    (>= (len worlds) u1)
    (<= (len worlds) u10)
    (fold check-world-exists worlds true)
  )
)

(define-private (check-world-exists
    (world-id uint)
    (valid bool)
  )
  (and valid (is-some (get-world-details world-id)))
)

;; UTILITY FUNCTIONS

(define-read-only (is-protocol-admin (sender principal))
  (default-to false (map-get? protocol-admin-whitelist sender))
)

(define-read-only (is-valid-principal (input principal))
  (and
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

(define-read-only (is-safe-principal (input principal))
  (and
    (is-valid-principal input)
    (or
      (is-protocol-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

(define-read-only (get-world-details (world-id uint))
  (map-get? game-worlds { world-id: world-id })
)

(define-read-only (get-avatar-details (avatar-id uint))
  (map-get? avatar-metadata { avatar-id: avatar-id })
)

(define-read-only (get-top-players)
  (let ((max-entries (var-get max-leaderboard-entries)))
    (list tx-sender)
  )
)

;; EXPERIENCE SYSTEM FUNCTIONS

(define-read-only (get-next-level-requirement (avatar-id uint))
  (match (get-avatar-details avatar-id)
    metadata (ok (calculate-level-up-experience (get level metadata)))
    ERR-INVALID-AVATAR
  )
)

(define-read-only (can-receive-experience
    (avatar-id uint)
    (experience-amount uint)
  )
  (match (get-avatar-details avatar-id)
    metadata (ok (and
      (< (get level metadata) MAX-LEVEL)
      (validate-experience-gain (get experience metadata) experience-amount
        (get level metadata)
      )
    ))
    ERR-INVALID-AVATAR
  )
)

(define-private (calculate-level-up-experience (current-level uint))
  (* BASE-EXPERIENCE-REQUIRED current-level)
)

(define-private (validate-experience-gain
    (current-experience uint)
    (gained-experience uint)
    (current-level uint)
  )
  (let (
      (max-allowed-gain (calculate-level-up-experience current-level))
      (new-total-experience (+ current-experience gained-experience))
    )
    (and
      (<= gained-experience max-allowed-gain)
      (<= new-total-experience (* MAX-EXPERIENCE-PER-LEVEL current-level))
    )
  )
)

(define-private (can-level-up
    (current-experience uint)
    (gained-experience uint)
    (current-level uint)
  )
  (let (
      (new-total-experience (+ current-experience gained-experience))
      (required-experience (calculate-level-up-experience current-level))
    )
    (>= new-total-experience required-experience)
  )
)

;; PROTOCOL MANAGEMENT FUNCTIONS

(define-public (initialize-protocol
    (entry-fee uint)
    (max-entries uint)
  )
  (begin
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= entry-fee u1) (<= entry-fee u1000)) ERR-INVALID-FEE)
    (asserts! (and (>= max-entries u1) (<= max-entries u500)) ERR-INVALID-ENTRIES)
    (var-set protocol-fee entry-fee)
    (var-set max-leaderboard-entries max-entries)
    (ok true)
  )
)

;; ASSET MANAGEMENT FUNCTIONS

(define-public (mint-nexus-asset
    (name (string-ascii 50))
    (description (string-ascii 200))
    (rarity (string-ascii 20))
    (power-level uint)
    (world-id uint)
    (attributes (list 10 (string-ascii 20)))
  )
  (let ((token-id (+ (var-get total-assets) u1)))
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-description description) ERR-INVALID-DESCRIPTION)
    (asserts! (is-valid-rarity rarity) ERR-INVALID-RARITY)
    (asserts! (is-valid-power-level power-level) ERR-INVALID-POWER-LEVEL)
    (asserts! (is-some (get-world-details world-id)) ERR-WORLD-NOT-FOUND)
    (asserts! (is-valid-attributes attributes) ERR-INVALID-ATTRIBUTES)
    (try! (nft-mint? nexus-asset token-id tx-sender))
    (map-set nexus-asset-metadata { token-id: token-id } {
      name: name,
      description: description,
      rarity: rarity,
      power-level: power-level,
      world-id: world-id,
      attributes: attributes,
      experience: u0,
      level: u1,
    })
    (var-set total-assets token-id)
    (ok token-id)
  )
)

(define-public (transfer-game-asset
    (token-id uint)
    (recipient principal)
  )
  (begin
    (asserts!
      (is-eq tx-sender
        (unwrap! (nft-get-owner? nexus-asset token-id) ERR-INVALID-GAME-ASSET)
      )
      ERR-NOT-AUTHORIZED
    )
    (asserts! (is-valid-principal recipient) ERR-INVALID-INPUT)
    (nft-transfer? nexus-asset token-id tx-sender recipient)
  )
)

;; AVATAR SYSTEM FUNCTIONS

(define-public (create-avatar
    (name (string-ascii 50))
    (world-access (list 10 uint))
  )
  (let ((avatar-id (+ (var-get total-avatars) u1)))
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-world-access world-access) ERR-INVALID-WORLD-ACCESS)
    (asserts! (is-none (map-get? leaderboard { player: tx-sender }))
      ERR-ALREADY-REGISTERED
    )
    (try! (nft-mint? nexus-avatar avatar-id tx-sender))
    (map-set avatar-metadata { avatar-id: avatar-id } {
      name: name,
      level: u1,
      experience: u0,
      achievements: (list),
      equipped-assets: (list),
      world-access: world-access,
    })
    (map-set leaderboard { player: tx-sender } {
      score: u0,
      games-played: u0,
      total-rewards: u0,
      avatar-id: avatar-id,
      rank: u0,
      achievements: (list),
    })
    (var-set total-avatars avatar-id)
    (ok avatar-id)
  )
)
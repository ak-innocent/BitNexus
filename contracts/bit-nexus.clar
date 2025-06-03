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
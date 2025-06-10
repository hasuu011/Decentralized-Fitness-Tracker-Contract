;; Decentralized Fitness Tracker Contract
;; A blockchain-based fitness tracking system for secure and transparent health data management

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-data (err u102))
(define-constant err-user-not-found (err u103))

;; Data structures
(define-map fitness-records 
  principal 
  {
    total-steps: uint,
    total-calories: uint,
    total-workouts: uint,
    last-updated: uint
  })

(define-map daily-activities
  {user: principal, date: uint}
  {
    steps: uint,
    calories-burned: uint,
    workout-duration: uint,
    activity-type: (string-ascii 50)
  })

;; Track total users
(define-data-var total-users uint u0)

;; Function 1: Record Daily Activity
;; Allows users to log their daily fitness activities
(define-public (record-activity (steps uint) (calories uint) (duration uint) (activity-type (string-ascii 50)))
  (let (
    (user tx-sender)
    (current-block-height block-height)
    (existing-record (map-get? fitness-records user))
  )
    ;; Validate input data
    (asserts! (and (> steps u0) (> calories u0) (> duration u0)) err-invalid-data)
    (asserts! (> (len activity-type) u0) err-invalid-data)
    
    ;; Record daily activity
    (map-set daily-activities 
      {user: user, date: current-block-height}
      {
        steps: steps,
        calories-burned: calories,
        workout-duration: duration,
        activity-type: activity-type
      })
    
    ;; Update or create fitness record
    (match existing-record
      record 
        (map-set fitness-records user
          {
            total-steps: (+ (get total-steps record) steps),
            total-calories: (+ (get total-calories record) calories),
            total-workouts: (+ (get total-workouts record) u1),
            last-updated: current-block-height
          })
      ;; First time user
      (begin
        (map-set fitness-records user
          {
            total-steps: steps,
            total-calories: calories,
            total-workouts: u1,
            last-updated: current-block-height
          })
        (var-set total-users (+ (var-get total-users) u1))
      )
    )
    
    (ok true)))

;; Function 2: Get User Fitness Summary
;; Retrieves comprehensive fitness data for a user
(define-read-only (get-fitness-summary (user principal))
  (let (
    (fitness-record (map-get? fitness-records user))
  )
    (match fitness-record
      record 
        (ok {
          user: user,
          total-steps: (get total-steps record),
          total-calories: (get total-calories record),
          total-workouts: (get total-workouts record),
          last-updated: (get last-updated record),
          average-steps-per-workout: (/ (get total-steps record) (get total-workouts record)),
          average-calories-per-workout: (/ (get total-calories record) (get total-workouts record))
        })
      err-user-not-found)))

;; Additional read-only functions for contract information
(define-read-only (get-daily-activity (user principal) (date uint))
  (map-get? daily-activities {user: user, date: date}))

(define-read-only (get-total-users)
  (ok (var-get total-users)))

(define-read-only (get-contract-owner)
  (ok contract-owner))
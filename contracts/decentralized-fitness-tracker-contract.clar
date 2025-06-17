
;; Decentralized Fitness Tracker Contract
;; Users can log workouts and view their fitness stats

(define-map fitness-logs
  { user: principal, day: uint }
  { steps: uint, calories: uint })

;; Function 1: Log fitness data for a day
(define-public (log-activity (day uint) (steps uint) (calories uint))
  (begin
    (map-set fitness-logs { user: tx-sender, day: day }
             { steps: steps, calories: calories })
    (ok true)))

;; Function 2: Get fitness log for a specific day
(define-read-only (get-log (user principal) (day uint))
  (ok (map-get? fitness-logs { user: user, day: day })))

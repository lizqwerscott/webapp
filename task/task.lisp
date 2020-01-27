(in-package :web-manager)

(defgeneric start-task (task-one)
  (:documentation "start the task"))

(defgeneric pause-task (task-one)
  (:documentation "pause the task"))

(defgeneric get-task-download-info (task-one key)
  (:documentation "get the key status from the task"))

(defgeneric show-task (task-one)
  (:documentation "show the task some info"))

(defgeneric unpause-task (task-one)
  (:documentation "unpause-task"))

;;;The Task class
(defclass task ()
    ((id
      :initarg :id
      :initform (error "Must supply a task id")
      :accessor task-id)
     (plist-info
       :initarg :pi
       :initform (error "Must supply a task info")
       :accessor task-pi)
     (run-status
        :initarg :run-status
        :initform "download"
        :accessor run-status)
     ;;Event
     (on-start 
       :initform (make-broadcast-event)
       :accessor task-on-start)
     (on-pause
       :initform (make-broadcast-event)
       :accessor task-on-pause)))

(defmethod pause-task ((task-one task))
  (setf (run-status task-one) "pause"))
  ;(pause-download (task-download-file task-one)))

(defmethod unpause-task ((task-one task))
  (setf (run-status task-one) "download"))
  ;(unpause-download (task-download-file task-one)))

(defmethod get-task-download-info ((task-one task) key))
  ;(get-download-info (task-download-file task-one) key))

(defmethod show-task ((task-one task))
  (format t "id:~a~%url:~a~%run-satatus:~a~%" 
          (slot-value task-one 'id) 
          (getf (task-pi task-one) :url) 
          (slot-value task-one 'run-status)))



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

(defgeneric update-task (task-one)
  (:documentation "finish the task"))

(defun get-thread-name ()
  (thread-name (current-thread)))

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
        :accessor run-status)))

(defmethod initialize-instance :after ((task-one task) &key)
  (format t "Now run the thread module~%"))

(defmethod start-task ((task-one task))
  (make-thread (lambda () (update-task task-one)) :name "thread1"))
 
(defmethod update-task ((task-one task))
  (format t "RUn:thread name:~A~%" (get-thread-name))
  (format t "Run:update-task:~a~%" (task-id task-one))
  (handle (download (add-table (task-pi task-one))))
  (setf (run-status task-one) "logging")
  (format t "Run:logging~%")
  (format t "Run:")
  (format t "End:update-task:~a~%" (task-id task-one)))
 

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



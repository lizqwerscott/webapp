;;;;To Manage all task
;;;;Time:2019.2.1 20:24 by lscott
;;;;The local path "TheWebApp/main.lisp"

(in-package :web-manager)

;;;Make event
(defun make-broadcast-event ()
  (make-instance 'broadcast-event))

;;;get the thread id[sample]
(defun get-thread-name ()
  (thread-name (current-thread)))

(defgeneric start-task (task-one)
  (:documentation "start the task"))

(defgeneric pause-task (task-one)
  (:documentation "pause the task"))

(defgeneric unpause-task (task-one)
  (:documentation "unpause-task"))

(defgeneric get-task-download-info (task-one key)
  (:documentation "get the key status from the task"))

(defgeneric show-task (task-one)
  (:documentation "show the task some info"))

(defgeneric update-task (task-one)
  (:documentation "finish the task"))

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

(defmethod initialize-instance :after ((task-one task) &key)
  (event+ (task-on-start task-one) #'update-task) task-one)

;;;The list of task
(defparameter *run-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Run task List")
;(defparameter *finish-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Finish task List")
;(defparameter *failure-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Failure task List")

(defmethod start-task ((task-one task))
  (event! (task-on-start task-one) task-one))

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

(defmethod update-task ((task-one task))
  (format t "Run:update-task:~a~%" (task-id task-one))
  (handle (download (add-table (task-pi task-one))))
  (setf (run-status task-one) "logging")
  (format t "Run:logging~%")
  (format t "Run:")
  (format t "End:update-task:~a~%" (task-id task-one)))

(defun show-list ()
  (doTimes (i (length *run-task-list*))
    (format t "[~a]:Start~%" (+ i 1))
    (show-task (elt *run-task-list* i))
    (format t "[~a]:End~%" (+ i 1))))

(defun find-task (id)
  (find id *run-task-list* :key #'task-id :test #'string=))

;;;About task some operating
(defun add-task (plist-info)
  "plist (:id :url :attributes :come-from :description :download-type)"
  (let ((task-one (make-instance 'task :id (getf plist-info :id) :pi plist-info)))
    (vector-push task-one *run-task-list*)
    (start-task task-one)))

(defun remove-task (id)
  (setf *run-task-list* (remove id *run-task-list* :key #'task-id :test #'string=)))

(in-package :cl-user)


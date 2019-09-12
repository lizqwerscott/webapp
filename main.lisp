;;;;To Manage all task
;;;;Time:2019.2.1 20:24 by lscott
;;;;The local path "TheWebApp/main.lisp"

(in-package :web-manager)

;;;Make event
(defun make-broadcast-event ()
  (make-instance 'broadcast-event))

;;;get the thread name[sample]
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
  	((name
    	:initarg :name
    	:initform (error "Must supply a task name")
     	:reader task-name)
     (url
       	:initarg :url
        :initform (error "Must supply a url")
        :reader task-url)
     (attributes 
       :initarg attributes
       :initform "Video"
       :reader task-attributes)
     (come-form 
       :initarg come-from
       :initform "LingMengYuShuo"
       :reader task-come-form)
     (description 
       :initarg description
       :reader task-description)
     (run-status
        :initarg :run-status
        :initform "download"
   		:accessor run-status)
     (download-file
       :accessor task-download-file)
     ;;Event
     (on-start 
       :initform (make-broadcast-event)
       :accessor task-on-start)
     (on-pause
       :initform (make-broadcast-event)
       :accessor task-on-pause)))

(defmethod initialize-instance :after ((task-one task) &key)
  (setf (task-download-file task-one) (make-download (name task-one) (url task-one)))
  (event+ (task-on-start task-one) #'update-task) task-one)

;;;The list of task
(defparameter *run-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Run task List")
;(defparameter *finish-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Finish task List")
;(defparameter *failure-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Failure task List")

(defmethod start-task ((task-one task))
  (event! (task-on-start task-one) task-one))

(defmethod pause-task ((task-one task))
  (setf (run-status task-one) "pause")
  (pause-download (task-download-file task-one)))

(defmethod unpause-task ((task-one task))
  (setf (run-status task-one) "download")
  (unpause-download (task-download-file task-one)))

(defmethod get-task-download-info ((task-one task) key)
  (get-download-info (task-download-file task-one) key))

(defmethod show-task ((task-one task))
  (format t "name:~a~%url:~a~%run-satatus:~a~%" 
          (slot-value task-one 'name) 
          (slot-value task-one 'url) 
          (slot-value task-one 'run-status)))

(defmethod update-task ((task-one task))
  (format t "Run:update-task:~a~%" (name task-one))
  (format t "Run:Download.~%")
  (let ((return-number 1))
    (do ((n 0 (+ n 1)))
        ((not (and (string= "download" (run-status task-one)) (string= "complete" (get-task-download-info task-one :status)))) return-number)
        ;;update-all-task
        (update-download (task-download-file task-one))))
  (run-shell (format nil "cd ~a" (gethash ":dir" (task-download-file task-one))))
  (run-shell (format nil "unrar x ~a" (gethash ":files" (task-download-file task-one))))
  (setf (run-status task-one) "logging")
  (format t "Run:logging~%")
  (add-table (task-name task-one) (task-url task-one) (task-attributes task-one) (task-come-form task-one) (task-description task-one) (taks-download-file task-one))
  (format t "Run:")
  (format t "End:update-task:~a~%" (name task-one)))

(defun show-list ()
  (doTimes (i (length *run-task-list*))
   	(format t "[~a]:Start~%" (+ i 1))
    (show-task (elt *run-task-list* i))
    (format t "[~a]:End~%" (+ i 1))))

(defun find-task (name)
  (find name *run-task-list* :key #'name :test #'string=))

;;;About task some operating
(defun add-task (name url)
  (let ((task-one (make-instance 'task :name name :url url)))
    (vector-push task-one *run-task-list*)
    (start-task task-one)))

(defun remove-task (name)
  (remove-download (task-download-file (find-task name)))
  (setf *run-task-list* (remove name *run-task-list* :key #'name :test #'string=)))

(defun run-manager () 
  (doTimes (i (length *run-task-list*))
    (format t "Run:run-manager~%")
    ;(bordeaux-threads:make-thread 'update-task :name (name (elt *run-task-list* i)))
    (event! (task-on-start (elt *run-task-list* i)) (name (elt *run-task-list* i)))))

(in-package :cl-user)


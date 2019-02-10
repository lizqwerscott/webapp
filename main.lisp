;;;;To Manage all task
;;;;Time:2019.2.1 20:24 by lscott
;;;;The local path "TheWebApp/main.lisp"

(ql:quickload "cl-events") ;load event
(ql:quickload "lparallel") ;load thread pool manager

(ql:quickload "cl-json") ;load json
(ql:quickload "websocket-driver") ;load websocket

;;;Make event
(defun make-broadcast-event ()
  (make-instance 'cl-events:broadcast-event))

;;;get the thread name[sample]
(defun get-thread-name ()
  (bordeaux-threads:thread-name (bordeaux-threads:current-thread)))

;;;load another module
(load "./aria2/aria2.lisp") ;load aria2 module

;;;The Task class
(defclass task ()
  	((name
    	:initarg :name
    	:initform (error "Must supply a task name")
     	:reader name)
     (url
       	:initarg :url
        :initform (error "Must supply a url")
        :reader url)
     (run-status
        :initarg :run-status
        :initform "Download"
   		:accessor run-status)
     (download-file
       :accessor task-download-file)
     ;;Event
     (on-start 
       :initform (make-broadcast-event)
       :accessor task-on-start)
     (on-stop
       :initform (make-broadcast-event)
       :accessor task-on-stop)))

(defmethod initialize-instance :after ((task-one task) &key)
  (setf (task-download-file task-one) (make-download (name task-one) (url task-one))))

;;;The list of task
(defparameter *run-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Run task List")
;(defparameter *finish-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Finish task List")
;(defparameter *failure-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Failure task List")

(defun find-task (name)
  (find name *run-task-list* :key #'name :test #'string=))

(defun update-task (name)
  (format t "Run:update-task:~a~%" name)
  (let ((task-one (find-task name)) (return-number 1));(get-thread-name))))
    (do ((n 0 (+ n 1)))
        ((and (string= "complete" (run-status task-one)) (string= "stop" (run-status task-one))) return-number)
      ;;update-all-task
      (when (not (string= "stop" (run-status task-one)))
        (update-download (task-download-file task-one)))))
  (format t "Update-task:End;~%"))

;;;About task some operating
(defun add-task (name url)
  (let ((task-one (make-instance 'task :name name :url url)))
    (vector-push task-one *run-task-list*)
    (cl-events:event+ (task-on-start task-one) #'update-task)))

(defun remove-task (name)
  (remove-download (task-download-file (find-task name)))
  (setf *run-task-list* (remove name *run-task-list* :key #'name :test #'string=)))

(defun stop-task (name)
  (let ((task-one (find-task name)))
    (setf (run-status task-one) "stop")
    (pause-download (task-download-file task-one))))

(defun restart-task (name)
  (let ((task-one (find-task name)))
    (setf (run-status task-one) "download")
    (unpause-download (task-download-file task-one))))

(defun get-task-download (name key)
  (get-staus (task-download-file (find-task name)) key))

(defun show-task (task-one)
  (format t "name:~a~%url:~a~%run-satatus:~a~%" (slot-value task-one 'name) (slot-value task-one 'url) (slot-value task-one 'run-status)))

(defun show-list ()
  (doTimes (i (length *run-task-list*))
   	(format t "[~a]:Start~%" (+ i 1))
    (show-task (elt *run-task-list* i))
    (format t "[~a]:End~%" (+ i 1))))

(defun run-manager () 
  (doTimes (i (length *run-task-list*))
    (format t "Run:run-manager~%")
    ;(bordeaux-threads:make-thread 'update-task :name (name (elt *run-task-list* i)))
    (cl-events:event! (task-on-start (elt *run-task-list* i)) (name (elt *run-task-list* i)))))

;(event-glue:bind "stop-task" (lambda (ev) (format t "[Event1]:name:stop-task,thread-name:~a" (get-thread-name))))
;(event-glue:bind "stop-task" (lambda (ev) (format t "[Event2]:name:stop-task,thread-name:~a" (get-thread-name))))
;(add-task "baidu" "https://baidu.com")
;(add-task "bilibili" "https://bilibili.com")
;(show-list *run-task-list*)
;(run-manager)
;(show-list *run-task-list*)
;(sleep 0.001)
;(stop-task "baidu")

;;;;To Manage all task
;;;;Time:2019.2.1 20:24 by lscott
;;;;The local path "TheWebApp/main.lisp"

(in-package :web-manager)

;;;The list of task
(defparameter *run-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Run task List")
;(defparameter *finish-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Finish task List")
;(defparameter *failure-task-list* (make-array 5 :fill-pointer 0 :adjustable t) "The Failure task List")

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


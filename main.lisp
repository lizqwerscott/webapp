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
  "plist (:id :url :attributes :tag :r18p :description :download-type :zipp :extractp :password :removep)"
  (let ((task-one (make-instance 'task :id (getf plist-info :id) :pi plist-info)))
    (vector-push task-one *run-task-list*)
    (start-task task-one)))

(defun prompt-for-task-list ()
  (list :id (prompt-read "Name") 
        :url (prompt-read "Url") 
        :attributes (want-to-self-input "Attributes" (list "video" "music" "picture"))
        ;:come-from (want-to-self-input "Come-from" (list "MS" "YY" "LingMeiYushuo"))
        :tag (prompt-read "Tag")
        :description (prompt-read "Description")
        :download-type (want-to-self-input "Download-type" (list "local" "common" "baidu"))
        :r18p (y-or-n-p "Is this is the r18?")
        :zipp (y-or-n-p "Do you want to zip?")
        :extractp (y-or-n-p "Do you want to extract?")
        :removep (y-or-n-p "Do you want to remove zip file?")
        :password (want-to-self-input "Password" (list "nil"))))

(defun pfts ()
  (loop (add-task (prompt-for-task-list))
        (if (not (y-or-n-p "Dow you want to continue?")) (return))))

(defun remove-task (id)
  (setf *run-task-list* (remove id *run-task-list* :key #'task-id :test #'string=)))

(in-package :cl-user)


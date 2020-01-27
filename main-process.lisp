(in-package :web-manager)

(defun make-broadcast-event ()
  (format nil "nil"))

(defmethod initialize-instance :after ((task-one task) &key)
  (format t "Now run the process module~%"))

(defun update-task (id pi-info)
  (format t "Run:update-task:~a~%" id)
  (handle (download (add-table pi-info)))
  (format t "End:update-task:~a~%" id))

(defmethod start-task ((task-one task))
  (let ((filename "~/task.txt")) 
    (with-open-file (out filename
                         :direction :output :if-exists :supersede)
      (with-standard-io-syntax 
        (print (task-pi task-one) out)))
    (run-shell (format nil "rlwrap sbcl --load ./task/task-update-task.lisp ~A ~A" (task-id task-one) filename) t)))

(in-package :cl-user)


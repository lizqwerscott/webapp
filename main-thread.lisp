(in-package :web-manager)

(defgeneric update-task (task-one)
  (:documentation "finish the task"))

;;;get the thread id[sample]
(defun get-thread-name ()
  (thread-name (current-thread)))

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
 

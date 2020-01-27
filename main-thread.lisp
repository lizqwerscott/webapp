(in-package :web-manager)

(defgeneric update-task (task-one)
  (:documentation "finish the task"))

;;;Make event
(defun make-broadcast-event ()
  (make-instance 'broadcast-event))

;;;get the thread id[sample]
(defun get-thread-name ()
  (thread-name (current-thread)))

(defmethod initialize-instance :after ((task-one task) &key)
  (format t "Now run the thread module~%")
  (event+ (task-on-start task-one) #'update-task) task-one)

(defmethod start-task ((task-one task))
  (event! (task-on-start task-one) task-one))
 
(defmethod update-task ((task-one task))
  (format t "Run:update-task:~a~%" (task-id task-one))
  (handle (download (add-table (task-pi task-one))))
  (setf (run-status task-one) "logging")
  (format t "Run:logging~%")
  (format t "Run:")
  (format t "End:update-task:~a~%" (task-id task-one)))
 

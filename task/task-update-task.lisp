(load "./use.lisp")

(web-manager:set-run-module "process")

(in-package :web-manager)

(let ((pi-info ()) (filename "~/task.txt")) 
  (with-open-file (in filename)
    (with-standard-io-syntax 
      (setf pi-info (read in))))
  (web-manager:update-task (getf pi-info :id) pi-info)
  (web-manager.head:run-shell (format nil "rm -rf ~a" filename) t))


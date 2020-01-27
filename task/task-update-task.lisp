(load "./use.lisp")

(web-manager:set-run-module "process")

(in-package :web-manager)

(let ((pi-info ()) (filename (nth 2 sb-ext:*posix-argv*))) 
  (with-open-file (in filename)
    (with-standard-io-syntax 
      (setf pi-info (read in))))
  (web-manager:update-task (nth 1 sb-ext:*posix-argv*) pi-info)
  (web-manager.head:run-shell (format nil "rm -rf ~a" filename) t))


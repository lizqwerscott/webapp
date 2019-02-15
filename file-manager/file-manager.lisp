;;;;The file manager
;;;;include a small database

(in-package :web-manager.file)

(defclass table ()
  ((name 
     :initarg :name
     :reader table-name)
   (path 
     :initarg :path
     :reader table-path)
   ()
   ))

(in-package :cl-user)


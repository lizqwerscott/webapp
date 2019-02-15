;;;;The file manager
;;;;include a small database

(in-package :web-manager.file)

(defun run-shell (cmd &optional (isDebug-p nil))
  (if isDebug-p 
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output *standard-output*)
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output nil)))

(defvar *table-manager-hash* (make-hash-table :test #'equal))

(defun add-table-group (key)
  (setf (gethash key *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t)))

(add-table-group "Video")
(add-table-group "Music")
(add-table-group "Game")
(add-table-group "MMD")

(defclass table ()
  ((name 
     :initarg :name
     :reader table-name)
   (path 
     :reader table-path)
   (b-path
     :accessor table-b-path
     )
   (y-path
     :accessor table-y-path
     )
   (url
     :initarg :url
     :reader table-url)
   (attributes
     :initarg :attributes
     :reader table-attributes)
   (date
     ;:initarg :date
     :reader table-date)
   (isNormal
     :initarg :isNormal
     :reader table-isNormal)
   (description
     :initarg :description
     :reader table-description)))

(defmethod make-table-dir ((table-one table))
  (let ((path (format nil "/mnt/myusbdrives/~a" (table-attributes table-one))))
    (if (table-isNormal table-one)
        (setf path (format nil "~a/Normal/~a" path (table-name table-one)))
        (setf path (format nil "~a/~a" path (table-name table-one))))
    (run-shell (format nil "mkdir ~a/" path))
    (run-shell (setf (table-y-path table-one) (format nil "mkdir ~a/Archive/" path)))
    (run-shell (setf (table-b-path table-one) (format nil "mkdir ~a/Ben/" path)))
    (setf (table-path table-one) path)))

(defmethod move-table ((table-one table) b-path y-path)
  (run-shell (format nil "mv -r ~a ~a" b-path (table-b-path table-one)))
  (run-shell (format nil "mv ~a ~a" y-path (table-y-path table-one))))

(defmethod initialize-instance :after ((table-one table) &key b-path y-path)
  (make-table-dir table-one)
  (move-table table-one b-path y-path))

(defun add-table (name url attributes isNormal description)
  (vector-push 
    (make-instance 'table :name name :url url :attributes attributes :isNormal isNormal :description description)
   (gethash attributes *table-manager-hash*)))

(defun remove-table (name attributes)
  (remove name 
          (gethash attributes *table-manager-hash*) 
          :key #'(lambda (table-one) 
                           (table-name table-one)) 
          :test #'string=))

(in-package :cl-user)


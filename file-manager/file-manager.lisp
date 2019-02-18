;;;;The file manager
;;;;include a small database
(in-package :web-manager.file)

(defun run-shell (cmd &optional (isDebug-p nil))
  (if isDebug-p 
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output *standard-output*)
     (sb-ext:run-program "/bin/sh" (list "-c" cmd) :input nil :output nil)))

(defvar *table-manager-hash* (make-hash-table :test #'equal))
;(defparameter *drive-path* "/mnt/myusbdrives/")
(defparameter *drive-path* (make-pathname :directory '(:absolute :home "Documents" "test-web")))

(defclass table ()
  ((name 
     :initarg :name
     :reader table-name)
   (path 
     :accessor table-path)
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
     :accessor table-date)
   (come-from
     :initarg :come-from
     :reader table-come-from)
   (description
     :initarg :description
     :reader table-description)))

;;;A very big problem will to change
;(defmethod make-table-dir ((table-one table))
;  (let ((path (format nil "~a~a" *drive-path*  (table-attributes table-one))))
;    (if (table-isNormal table-one)
;        (setf path (format nil "~a/Normal/~a" path (table-name table-one)))
;        (setf path (format nil "~a/~a" path (table-name table-one))))
;    (run-shell (format nil "mkdir ~a/" path))
;    (run-shell (setf (table-y-path table-one) (format nil "mkdir ~a/Archive/" path)))
;    (run-shell (setf (table-b-path table-one) (format nil "mkdir ~a/Ben/" path)))
;    (setf (table-path table-one) path)))

(defmethod make-table-dir ((table-one table))
  (let ((path (merge-pathnames (pathname (format nil "~a/~a/~a/" (table-attributes table-one) (table-come-from table-one) (table-name table-one))) *drive-path*)))
    (setf (table-y-path table-one) (ensure-directories-exist (merge-pathnames (pathname (format nil "Archive/")) path)))
    (setf (table-b-path table-one) (ensure-directories-exist (merge-pathnames (pathname (format nil "Ben/")) path)))
    (setf (table-path table-one) path)))

(defmethod move-table ((table-one table) b-path y-path)
  (run-shell (format nil "mv ~a ~a" b-path (table-b-path table-one)))
  (run-shell (format nil "mv ~a ~a" y-path (table-y-path table-one))))

;(defmethod save-table ((table-one table))
;  (let ((plist (list :name (table-name table-one) :path (table-path table-one) :b-path (table-b-path table-one) :y-path (table-y-path table-one) :url (table-url table-one) :attributes (table-attributes table-one) :date (table-date table-one) :come-from (table-come-from table-one) :description (table-description table-one))))
    
;    ))
;(add-table "hello" "http://baidu.com" "Video" "LingMengYuShuo" "The test" "~/Documents/test-web/Downloads/test" "~/Documents/test-web/Downloads/test.rar")

;(vector-push-extend 'a (gethash "Video" *table-manager-hash*))
;(setf (gethash "Video" *table-manager-hash*) (remove 'a (gethash "Video" *table-manager-hash*)))
;(setf (gethash "Video" *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))

;(remove-table "hello" "Video")
;(save-table (find "hello" (gethash "Video" *table-manager-hash*) :test #'string= :key #'(lambda (table-one) (table-name table-one))))

(defmethod save-table ((table-one table))
  (with-open-file (out (merge-pathnames (make-pathname :name "info" :type "txt") (table-b-path table-one)) :direction :output :if-exists :supersede)
    (with-standard-io-syntax
      (print table-one out))))

(defmethod initialize-instance :after ((table-one table) &key b-path y-path)
  (make-table-dir table-one)
  (move-table table-one b-path y-path)
  (setf (table-date table-one) "2019.2.17.22:10"))

(defmethod reinitialize-instance :before ((table-one table) &key)
  (run-shell (format nil "rm -rf ~a" (namestring (table-path table-one))) t))

(defun load-table-group (key)
  (setf (gethash key *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))
  (let ((path (merge-pathnames (pathname (format nil "~a/" key)) *drive-path*))
        (table-group (gethash key *table-manager-hash*))) 
    (if (not (probe-file path))
      (ensure-directories-exist path)
      (dolist (table-one-path (directory (merge-pathnames (make-pathname :name :wild :type :wild) path)))
        ()
        ))))

(defun load-table-manager ()
  ()
  )

(defun add-table (name url attributes come-from description b-path y-path)
  (vector-push 
    (make-instance 'table :name name :url url :attributes attributes :come-from come-from :description description :b-path b-path :y-path y-path)
   (gethash attributes *table-manager-hash*)))

(defun remove-table (name attributes)
  (setf (gethash attributes *table-manager-hash*) 
        (remove name 
          (gethash attributes *table-manager-hash*) 
          :key #'(lambda (table-one) 
                           (table-name table-one)) 
          :test #'string=)))

(load-table-group "Video")
(load-table-group "Music")
(load-table-group "Game")
(load-table-group "MMD")

(in-package :cl-user)


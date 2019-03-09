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
     :initarg :date
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

(defmethod save-table ((table-one table))
  (let ((plist (list :name (table-name table-one) :path (table-path table-one) :b-path (table-b-path table-one) :y-path (table-y-path table-one) :url (table-url table-one) :attributes (table-attributes table-one) :date (table-date table-one) :come-from (table-come-from table-one) :description (table-description table-one))))
    (with-open-file (out (merge-pathnames (make-pathname :name "info" :type "txt") (table-path table-one)) :direction :output :if-exists :supersede)
      (with-standard-io-syntax 
        (print plist out))) plist))


;(add-table "hello" "http://baidu.com" "Video" "LingMengYuShuo" "The test" "~/Documents/test-web/Downloads/test" "~/Documents/test-web/Downloads/test.rar")

;(vector-push-extend 'a (gethash "Video" *table-manager-hash*))
;(setf (gethash "Video" *table-manager-hash*) (remove 'a (gethash "Video" *table-manager-hash*)))
;(setf (gethash "Video" *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))

;(table-path (elt (gethash "Video" *table-manager-hash*) 0)) 
;(remove-table "hello" "Video")
;(save-table (find "hello" (gethash "Video" *table-manager-hash*) :test #'string= :key #'(lambda (table-one) (table-name table-one))))

(defmethod initialize-instance :after ((table-one table) &key loadp b-path y-path)
  (when loadp 
    (make-table-dir table-one)
    (move-table table-one b-path y-path)) 
  (setf (table-date table-one) "2019.2.17.22:10"))

(defun load-table (path)
  (let* ((plist (with-open-file (in (merge-pathnames (make-pathname :name "info" :type "txt") path)) (with-standard-io-syntax (read in))))
         (table-one (make-instance 'table :name (getf plist :name) :url (getf plist :url) :attributes (getf plist :attributes) :come-from (getf plist :come-from) :description (getf plist :description) :b-path (getf plist :b-path) :y-path (getf plist :y-path) :date (getf plist :date) :loadp nil)))
    (setf (table-path table-one) (getf plist :path)) table-one))

(defun load-table-group (path)
  (let* ((key (car (last (pathname-directory path))))
        (table-group (gethash key *table-manager-hash*))) 
    (setf (gethash key *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))
    (if (not (probe-file path))
      (ensure-directories-exist path)
      (dolist (table-come-path (directory (merge-pathnames (make-pathname :name :wild :type :wild) path)))
        (dolist (table-one-path (directory (merge-pathnames (make-pathname :name :wild :type :wild) table-come-path))) 
          (vector-push (load-table table-one-path) (gethash key *table-manager-hash*)))))))

(defun load-table-manager ()
  (dolist (table-one-group (directory (merge-pathnames (make-pathname :name :wild :type :wild) *drive-path*)))
    (when (not (string= (car (last (pathname-directory table-one-group))) "Downloads")) (load-table-group table-one-group))))

(defun add-table (name url attributes come-from description b-path y-path &optional (date nil))
  (let (table-one (make-instance 'table :name name :url url :attributes attributes :come-from come-from :description description :b-path b-path :y-path y-path :date date :loadp t))
    (vector-push table-one (gethash attributes *table-manager-hash*))
    (save-table table-one) table-one))

(defun remove-table (name attributes)
  (run-shell (format nil "rm -rf ~a" (namestring (table-path (find name (gethash attributes *table-manager-hash*) :key #'(lambda (table-one) (table-name table-one)) :test #'string=)))) t)
  (setf (gethash attributes *table-manager-hash*) 
        (delete name 
          (gethash attributes *table-manager-hash*) 
          :key #'(lambda (table-one) 
                           (table-name table-one)) 
          :test #'string=)))

(load-table-manager)
;(load-table-group "Video")
;(load-table-group "Music")
;(load-table-group "Game")
;(load-table-group "MMD")

(in-package :cl-user)


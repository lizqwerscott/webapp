;;;;The file manager
;;;;include a small database
(in-package :web-manager.file)

(defvar *table-manager-hash* (make-hash-table :test #'equal))

(defclass table ()
  ((id 
     :initarg :id
     :reader table-id)
   (plist-info 
     :initarg :pi
     :initform (error "Must add the plist-info(tabel")
     :accessor table-pi)
   (date
     :initarg :date
     :accessor table-date)))

;;;A very big problem will to change
;(defmethod make-table-dir ((table-one table))
;  (let ((path (format nil "~a~a" *drive-path*  (table-attributes table-one))))
;    (if (table-isNormal table-one)
;        (setf path (format nil "~a/Normal/~a" path (table-id table-one)))
;        (setf path (format nil "~a/~a" path (table-id table-one))))
;    (run-shell (format nil "mkdir ~a/" path))
;    (run-shell (setf (table-y-path table-one) (format nil "mkdir ~a/Archive/" path)))
;    (run-shell (setf (table-b-path table-one) (format nil "mkdir ~a/Ben/" path)))
;    (setf (table-path table-one) path)))

(defmethod make-table-dir ((table-one table))
  (let* ((tablepi (table-pi table-one)) (path (merge-pathnames (pathname (format nil "~a/~a/~a/" (getf tablepi :attributes) (getf tablepi :come-from) (table-id table-one))) (get-drive-path))))
    (setf (getf (table-pi table-one) :y-path) (ensure-directories-exist (merge-pathnames (pathname (format nil "Archive/")) path)))
    (setf (getf (table-pi table-one) :b-path) (ensure-directories-exist (merge-pathnames (pathname (format nil "Ben/")) path)))
    (setf (getf (table-pi table-one) :path) path)))

;(defmethod move-table ((table-one table) y-path)
;  (run-shell (format nil "mv ~a ~a" y-path (getf (table-pi table-one) :y-path)))
  ;(let ((y-now-path (format nil "~a" (namestring (merge-pathnames (let ((temppath (pathname y-path))) (pathname :id (pathname-name temppath) :type (pathname-type temppath))) (table-b-path table-one))))))
;  (let ((y-now-path 
;          (format nil "~a" (namestring 
;                             (merge-pathnames 
                      ;         (let ((temppath (pathname y-path)))
                               ;  (make-pathname :name (pathname-name temppath) :type (pathname-type temppath))) 
                               ;(table-b-path table-one))))))
    ;(run-shell (format nil "cd ~a" (table-b-path table-one)))
    ;(run-shell (format nil "unrar x ~a" y-now-path) t) ;Wait to test
    ;(run-shell (format nil "mv ~a ~a" y-now-path (getf (table-pi table-one) :y-path)))

(defmethod save-table ((table-one table))
  (let ((plist (table-pi table-one)))
    (with-open-file (out (merge-pathnames (make-pathname :name "info" :type "txt") (getf (table-pi table-one) :path)) :direction :output :if-exists :supersede)
      (with-standard-io-syntax 
        (print plist out))) plist))


;(add-table "hello" "http://baidu.com" "Video" "LingMengYuShuo" "The test" "~/Documents/test-web/Downloads/test.rar")

;(vector-push-extend 'a (gethash "Video" *table-manager-hash*))
;(setf (gethash "Video" *table-manager-hash*) (remove 'a (gethash "Video" *table-manager-hash*)))
;(setf (gethash "Video" *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))

;(table-path (elt (gethash "Video" *table-manager-hash*) 0)) 
;(remove-table "hello" "Video")
;(save-table (find "hello" (gethash "Video" *table-manager-hash*) :test #'string= :key #'(lambda (table-one) (table-id table-one))))

(defmethod initialize-instance :after ((table-one table) &key loadp)
  (unless loadp 
    (make-table-dir table-one)
    (setf (table-date table-one) "2019.2.17.22:10")))
    ;(move-table table-one y-path)) )

(defun load-table (path)
  (format t "load-table:path~A~%" path)
  (let* ((plist (with-open-file (in (merge-pathnames (make-pathname :name "info" :type "txt") path)) (with-standard-io-syntax (read in))))
         (table-one (make-instance 'table :id (getf plist :id) :pi plist :date (getf plist :date) :loadp t)))
    (setf (getf (table-pi table-one) :path) (getf plist :path)) table-one))

(defun load-table-group (path)
  (let* ((key (car (last (pathname-directory path))))) 
    (setf (gethash key *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))
    (if (not (probe-file path))
      (ensure-directories-exist path)
      (dolist (table-come-path (directory (merge-pathnames (make-pathname :name :wild :type :wild) path)))
        (dolist (table-one-path (directory (merge-pathnames (make-pathname :name :wild :type :wild) table-come-path))) 
          (vector-push (load-table table-one-path) (gethash key *table-manager-hash*)))))))

(defun load-table-manager ()
  (dolist (table-one-group (directory (merge-pathnames (make-pathname :name :wild :type :wild) (get-drive-path))))
    (when (not (string= (car (last (pathname-directory table-one-group))) "Downloads")) 
      (load-table-group table-one-group))))

(defun add-table (plist-info &optional (date "nil"))
  (let ((table-one (make-instance 'table :id (getf plist-info :id) :pi (append plist-info (list :date date :path nil)) :date date :loadp nil)))
    (vector-push table-one (gethash (getf (table-pi table-one) :attributes) *table-manager-hash*))
    (save-table table-one) (table-pi table-one)))

(defun remove-table (id attributes)
  (run-shell (format nil "rm -rf ~a" (namestring (getf (table-pi (find id (gethash attributes *table-manager-hash*) :key #'(lambda (table-one)
                      (table-id table-one)) :test #'string=)) :path))) t)
  (setf (gethash attributes *table-manager-hash*) 
        (delete id 
          (gethash attributes *table-manager-hash*) 
          :key #'(lambda (table-one) 
                           (table-id table-one)) 
          :test #'string=)))

(defun search-table (name &optional (attributes "Video" attributes-supplied-p))
  (if attributes-supplied-p
     (find name (gethash attributes *table-manager-hash*) :test #'string= :key #'(lambda (table-one) 
                                                                                   (table-id table-one)))
     (maphash #'(lambda (k v) 
                  (format t "key:~A" k)
                  (find name v :test #'string= :key #'(lambda (table-one)
                                                                    (table-id table-one))))
              *table-manager-hash*)))

(defun show-table ()
  (format t "Show Table:-------------~%")
  (maphash #'(lambda (k v)
               (format t "key:~A,length:~A~%" k (length v))
               (doTimes (i (length v))
                        (format t "id:~A~%" (getf (table-pi (elt v i)) :id))))
           *table-manager-hash*)
  (format t "End:--------------------~%"))

(load-table-group "Video")
;(load-table-group "Music")
;(load-table-group "Game")
;(load-table-group "MMD")

(in-package :cl-user)


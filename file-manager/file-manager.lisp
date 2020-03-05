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

(defmethod make-table-dir ((table-one table))
  (let* ((tablepi (table-pi table-one)) (path (merge-pathnames (pathname (format nil "~a/~a/~a/" (getf tablepi :attributes) (getf tablepi :come-from) (table-id table-one))) (get-drive-path))))
    (setf (getf (table-pi table-one) :y-path) (ensure-directories-exist (merge-pathnames (pathname (format nil "Archive/")) path)))
    (setf (getf (table-pi table-one) :b-path) (ensure-directories-exist (merge-pathnames (pathname (format nil "Ben/")) path)))
    (setf (getf (table-pi table-one) :path) path)))

(defmethod save-table ((table-one table))
  (let ((plist (table-pi table-one)))
    (with-open-file (out (merge-pathnames (make-pathname :name "info" :type "txt") (getf (table-pi table-one) :path)) :direction :output :if-exists :supersede)
      (with-standard-io-syntax 
        (print plist out))) plist))

(defmethod initialize-instance :after ((table-one table) &key loadp)
  (unless loadp 
    (make-table-dir table-one)
    (setf (table-date table-one) "2019.2.17.22:10")))

(defmethod archivep-table ((table-one table)) 
  (empty-dirp (getf (table-pi table-one) :y-path)))

(defmethod benp-table ((table-one table)) 
  (empty-dirp (getf (table-pi table-one) :b-path)))

(defmethod zip-table ((table-one table)) 
  (if (not (archivep-table table-one)) 
      (let* ((plist-info (table-pi table-one)) 
            (need-zip-files (directory-e (getf plist-info :b-path)))) 
        (zip-file need-zip-files (getf plist-info :b-path) (getf plist-info :id)) 
        (move-file (merge-pathnames (format nil "~A.zip" (getf plist-info :id)) (getf plist-info :b-path)) 
                   (getf plist-info :y-path))) 
      (error "Table:~A, the archive is not nil" (table-id table-one))))

(defmethod extract-table ((table-one table)) 
  (if (not (benp-table table-one)) 
      (let ((plist-info (table-pi table-one))) 
        (dolist (i (nth 0 (find-compressed (getf plist-info :y-path)))) 
          (extract i (getf plist-info :b-path) (getf plist-info :password)))) 
      (error "Table:~A, the ben is not nil" (table-id table-one))))

(defmethod delete-table ((table-one table)) 
  (let ((pi-info (table-pi table-one))) 
    (delete-directory-tree (getf pi-info :path) :validate t) 
    (setf (gethash (getf pi-info :attributes) *table-manager-hash*) 
        (delete (table-id table-one) 
                (gethash (getf pi-info :attributes) *table-manager-hash*)
                :key #'(lambda (table-s)
                         (table-id table-s))
                :test #'string=))))

(defmethod check-table ((table-one table) deletep zipp extractp show-heathp)
  (let ((archive (archivep-table table-one))
        (ben (benp-table table-one)))
    (if (not (or archive ben))
            (progn (format t "Table:~A is empty table, need to delete;~%" (table-id table-one)) 
                   (if deletep (progn (format t "Table:~A wil be delete~%" (table-id table-one))
                                      (delete-table table-one))))
            (if (and ben (not archive))
                (progn (format t "Table:~A dont't have archive~%" (table-id table-one)) 
                       (when zipp 
                         (format t "Table:~A will be extract~%" (table-id table-one)) 
                         (zip-table table-one)))
                (if (and archive (not ben))
                    (progn (format t "Table:~A don't have ben.~%" (table-id table-one)) 
                           (when extractp 
                             (format t "Table:~A will be zip~%" (table-id table-one)) 
                             (extract-table table-one))) 
                    (if show-heathp (format t "Table:~A is health~%" (table-id table-one))))))))

(defun load-table (path)
  (format t "load-table:path~A~%" path)
  (let* ((plist (with-open-file (in (merge-pathnames (make-pathname :name "info" :type "txt") path)) 
                  (with-standard-io-syntax (read in))))
         (table-one (make-instance 'table :id (getf plist :id) :pi plist :date (getf plist :date) :loadp t)))
    (setf (getf (table-pi table-one) :path) (getf plist :path)) table-one))

(defun load-table-group (path)
  (let* ((key (car (last (pathname-directory path))))) 
    (setf (gethash key *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))
    (if (not (probe-file path))
      (ensure-directories-exist path)
      (dolist (table-come-path (directory* (merge-pathnames (make-pathname :name :wild :type :wild) path)))
        (dolist (table-one-path (directory* (merge-pathnames (make-pathname :name :wild :type :wild) table-come-path))) 
          (vector-push-extend (load-table table-one-path) (gethash key *table-manager-hash*)))))))

(defun load-table-manager ()
  (dolist (table-one-group (directory* (merge-pathnames (make-pathname :name :wild :type :wild) (get-drive-path))))
    (when (not (string= (car (last (pathname-directory table-one-group))) "Downloads")) 
      (load-table-group table-one-group))))

(defun add-table (plist-info &optional (date "nil"))
  (let ((table-one (make-instance 'table :id (getf plist-info :id) :pi (append plist-info (list :date date :path nil)) :date date :loadp nil)))
    (vector-push-extend table-one (gethash (getf (table-pi table-one) :attributes) *table-manager-hash*))
    (save-table table-one) (table-pi table-one)))

(defun remove-table (id attributes)
  (delete-table (search-table id attributes))
  (run-shell (format nil "rm -rf ~a" (unix-namestring (getf (table-pi (find id (gethash attributes *table-manager-hash*) :key #'(lambda (table-one)
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
     (let ((find-table-one nil)) 
       (maphash #'(lambda (k v) 
                  (setf find-table-one (find name v :test #'string= 
                                                :key #'(lambda (table-one)
                                                         (table-id table-one)))))
                *table-manager-hash*) 
       find-table-one)))

(defun show-table ()
  (format t "Show Table:-------------~%")
  (maphash #'(lambda (k v)
               (format t "key:~A,length:~A~%" k (length v))
               (doTimes (i (length v))
                        (format t "id:~A~%" (getf (table-pi (elt v i)) :id))))
           *table-manager-hash*)
  (format t "End:--------------------~%"))

(defun check-all-table (&key (deletep nil) (zipp nil) (extractp nil) (show-heathp t))
  (maphash #'(lambda (k v)
               (map 'vector #'(lambda (table)
                                (check-table table deletep zipp extractp show-heathp)) v)) *table-manager-hash*))

;(load-table-group "Video")
;(load-table-group "Music")
;(load-table-group "Game")
;(load-table-group "MMD")
(load-table-manager)

(in-package :cl-user)


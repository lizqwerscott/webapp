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
  (let* ((tablepi (table-pi table-one))
         (path (make-next-dir (list "Files"
                                    (getf tablepi :attributes)
                                    (if (getf tablepi :r18p) "r18" "normal")
                                    (getf tablepi :tag)
                                    (getf tablepi :id))
                              (get-drive-path))))
    (setf (getf (table-pi table-one) :path) path)))

(defmethod initialize-instance :after ((table-one table) &key loadp)
  (unless loadp 
    (make-table-dir table-one)
    (setf (table-date table-one) "2019.2.17.22:10")))

(defmethod save-table ((table-one table))
  (save-plist-file (table-pi table-one)
                   (make-pathname :name "info"
                                  :type "txt"
                                  :defaults (getf (table-pi table-one) :path))))


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
  (let ((plist (load-plist-file (make-pathname :name "info"
                                               :type "txt"
                                               :defaults path))))
    (make-instance 'table
                   :id (getf plist :id)
                   :pi plist
                   :date (getf plist :date)
                   :loadp t)))

(defun load-table-group (path)
  (let ((key (last1 (pathname-directory path)))) 
    (setf (gethash key *table-manager-hash*) (make-array 10 :fill-pointer 0 :adjustable t))
    (if (not (probe-file path))
      (ensure-directories-exist path)
      (progn
        ;;normal directory
        (dolist (table-tag-path (directory-e (make-next-dir "normal" path)))
          (dolist (table-one-path (directory-e table-tag-path))
            (vector-push-extend (load-table table-one-path)
                                (gethash key *table-manager-hash*))))
        ;;r18 directory
        (dolist (table-tag-path (directory-e (make-next-dir "r18" path)))
          (dolist (table-one-path (directory-e table-tag-path))
            (vector-push-extend (load-table table-one-path)
                                (gethash key *table-manager-hash*))))))))

(defun load-table-manager ()
  (dolist (group (directory-e (make-next-dir "Files" (get-drive-path))))
    (load-table-group group)))

(defun add-table (plist-info &optional (date "nil"))
  (format t "add-table plist:~A~%" plist-info)
  (if (string= "add-table" (getf plist-info :status))
      (let ((table-one (make-instance 'table :id (getf plist-info :id)
                                             :pi (append plist-info
                                                         (list :date date
                                                               :path nil))
                                             :date date
                                             :loadp nil)))
        (vector-push-extend table-one
                            (gethash (getf (table-pi table-one)
                                           :attributes)
                                     *table-manager-hash*))
        (save-table table-one)
        (save-plist-file (update-plist-key (table-pi table-one)
                                           :status
                                           "download")
                         (get-task-save-path (getf (table-pi table-one) :id))))
      plist-info))

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
                    (let ((fins (find name v :test #'string= :key #'table-id))) 
                      (if fins 
                          (setf find-table-one fins))))
                *table-manager-hash*) 
       (if find-table-one 
           find-table-one 
           (progn (format t "Not find") find-table-one)))))

(defun show-table ()
  (format t "Show Table:-------------~%")
  (maphash #'(lambda (k v)
               (format t "key:~A,length:~A~%" k (length v))
               (doTimes (i (length v))
                        (format t "id:~A~%" (getf (table-pi (elt v i)) :id))))
           *table-manager-hash*)
  (format t "End:--------------------~%"))

(defun check-all-table (&key (deletep nil) (zipp nil) (extractp nil) (show-healthp t))
  (maphash #'(lambda (k v)
               (format t "key:~A,length:~A~%" k (length v))
               (map 'vector
                    #'(lambda (table)
                        (check-table table deletep zipp extractp show-healthp))
                    v))
           *table-manager-hash*))

;(load-table-group "Video")
;(load-table-group "Music")
;(load-table-group "Game")
;(load-table-group "MMD")
(load-table-manager)

(in-package :cl-user)


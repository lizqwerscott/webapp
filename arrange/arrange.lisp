(in-package :web-manager.arrange)

(defun create-plist-info (dir b-path y-path come-from attributes) 
  (let* ((directory-dir (pathname-directory dir))
         (l (length directory-dir))
         (id (nth (- l 1) directory-dir)))
    (list :path dir :b-path b-path :y-path y-path :id id :url "nil" :attributes attributes :come-from come-from :description id :download-type "local" :zipp t :password "nil")))

(defun handle-dir (dir come-from attributes)
  (let* ((files-dirs (find-compressed dir)) 
        (b-path (make-pathname :defaults (format nil "~ABen/" (namestring dir))))
        (y-path (make-pathname :defaults (format nil "~AArchive/" (namestring dir)))) 
        (plist-info (create-plist-info dir b-path y-path come-from attributes)))
    (run-shell (format nil "cd ~A && mkdir Ben && mkdir Archive" dir))
    (move-files (nth 0 files-dirs) b-path)
    (move-files (append (nth 1 files-dirs) (nth 2 files-dirs)) y-path)
    (with-open-file (out (format nil "~Ainfo.txt" (namestring dir)) :direction :output :if-exists :supersede)
      (with-standard-io-syntax
        (print plist-info out)))))

;;The .file and the vimrc will be the dir
(defun get-directory-name (dir)
  (if (and (pathname-name dir) (pathname-type dir))
      (progn (format t "Not the dir~%") (error "Not the dir"))
      (if (pathname-name dir)
        (pathname-name dir)
        (car (last (pathname-directory dir))))))

(defun arrange (path) 
  (let ((attributess (nth 2 (find-compressed path))))
    (dolist (attributes attributess) 
      (let ((come-froms (nth 2 (find-compressed attributes))))
        (dolist (come-from come-froms) 
          (let ((dirs (nth 2 (find-compressed come-from))))
            (dolist (dir dirs) 
              (handle-dir dir (get-directory-name come-from) (get-directory-name attributes)))))))))

(in-package :cl-user)


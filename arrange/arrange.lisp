(in-package :web-manager.arrange)

(defun create-plist-info (dir b-path y-path come-from attributes) 
  (let* ((directory-dir (pathname-directory dir))
         (l (length directory-dir))
         (id (nth (- l 1) directory-dir)))
    (list :path dir :b-path b-path :y-path y-path :id id :url "nil" :attributes attributes :come-from come-from :description id :download-type "local" :extractp t :zipp t :password "nil")))

(defun handle-dir (dir come-from attributes)
  (if (and (probe-file (merge-pathnames #P"info.txt" dir)))
    (format t "Don't need to run~%")
    (let* ((files-dirs (find-compressed dir)) 
          (b-path (merge-pathnames #P"Ben/" dir))
          (y-path (merge-pathnames #P"Archive/" dir)) 
          (plist-info (create-plist-info dir b-path y-path come-from attributes)))
      (format t "Handle-----------:Mkdir Ben and Archive~%")
      (ensure-directories-exist b-path)
      (ensure-directories-exist y-path)
      ;(run-shell (format nil "sudo cd ~A && sudo mkdir Ben && sudo mkdir Archive" dir))
      (format t "-------------------------------------Finish")
      (move-files (nth 0 files-dirs) y-path)
      (move-files-or-dirs (append (nth 1 files-dirs) (nth 2 files-dirs)) b-path)
      (with-open-file (out (format nil "~Ainfo.txt" (namestring dir)) :direction :output :if-exists :supersede)
        (with-standard-io-syntax
          (print plist-info out))))))

;;The .file and the vimrc will be the dir
(defun get-directory-name (dir)
  (if (and (pathname-name dir) (pathname-type dir))
      (progn (format t "Not the dir~%") (error "Not the dir"))
      (if (pathname-name dir)
        (pathname-name dir)
        (car (last (pathname-directory dir))))))

(defun arrange (path) 
  (let ((attributess (nth 2 (find-compressed path))))
    (format t "Path:~A~%" (namestring path))
    (dolist (attributes attributess) 
      (format t "att:~A~%" (namestring attributes))
      (let ((come-froms (nth 2 (find-compressed attributes))))
        (dolist (come-from come-froms) 
          (format t "--come:~A~%" (namestring come-from))
          (let ((dirs (nth 2 (find-compressed come-from))))
            (dolist (dir dirs) 
              (format t "----dir:~A~%" (namestring dir))
              (handle-dir dir (get-directory-name come-from) (get-directory-name attributes))
              ;(run-shell (format nil "sudo rm -rf ~AArchive && sudo rm -rf ~ABen" (namestring dir) (namestring dir)))
              ;(run-shell (format nil "sudo rm -rf ~Ainfo.txt" (namestring dir)))
              )))))))

(in-package :cl-user)


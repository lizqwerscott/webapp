(in-package :web-manager.download)

(defvar *conn* (make-instance 'cl-transmission:transmission-connection
                              :host "192.168.3.3"
                              :credentials '("transmission" "transmission")))

(defun download-bt-test ()
  (setf *conn* (make-instance 'transmission-connection
                              :host "127.0.0.1"
                              :credentials '(("lizqwer" "12138")))))

(download-bt-test)

(defun get-bt-url-hashstring (url)
  (subseq (car (last (split url ":"))) 0 40))

(defun remove-last-char (str)
  (subseq str 0 (- (length str) 1)))

(defun add-bt (url path)
  (transmission-add *conn*
                    :filename url
                    :download-dir (remove-last-char (namestring path))))

(defun handle-bt (bt)
  (list (format nil "~A" (gethash :name bt))
        (format nil "速度:~AMB/s" (float (/ (gethash :rate-download bt) (* 1024 1024))))
        (format nil "进度:~A" (let ((total (gethash :total-size bt))
                                    (left (gethash :left-until-done bt)))
                                (if (= total 0)
                                    "0%"
                                    (format nil "~A%" (float (* 100 (/ (- total left) total)))))))))

(defun get-bt ()
  (transmission-get *conn*
                    #(:name :hash-string :rate-download :total-size :left-until-done :status)
                    :strict t))

(defun find-bt (url)
  (find (get-bt-url-hashstring url)
        (get-bt)
        :key #'(lambda (x)
                 (gethash :hash-string x))
        :test #'string=))

(defun check-finish (url path)
  (let ((bt (find-bt url)))
    (if bt
        (= 6 (gethash :status bt))
        (not (add-bt url path)))))

(defun download-bt (plist)
  (format t "download in bt")
  ;;;根据hashstring 判断本次下载的bt
  ;;;先判断是否已经上传, 再上传磁力
  ;;;上传磁力
  (when (not (find-bt (getf plist :url)))
      (add-bt (getf plist :url) (getf plist :path)))
  ;;;检测磁力是否下载完
  (do ((finish (check-finish (getf plist :url)
                             (getf plist :path))
               (check-finish (getf plist :url)
                             (getf plist :path))))
      (finish 'done)
    (sleep 30)))

(defun download-baidu (plist)
  (format t "download in baidu yun.ID:~A~%" (getf plist :id)))

(defun download-common (plist)
  (format t "download in common~%")
  (run-shell (format nil "wget -P ~A ~A" (namestring (getf plist :path)) (getf plist :url)) t))

(defun download-local (plist)
  (format t "download in local~%")
  (let ((dir-name (make-next-dir (list "Download" (getf plist :id))
                                 (get-drive-path))))
    (format t "Download local path:~A~%" (namestring dir-name))
    (move-dir-all dir-name (getf plist :path))
    (if (not (directory-e dir-name))
        (delete-empty-directory dir-name)
        (error "the move is error")))
  (format t "download finish~%"))

;;;;除了local之外其他都直接下载到创建好的目录里面
(defun download (plist)
  (format t "download plist:~A~%" plist)
  (if (string= (getf plist :status) "download")
      (progn
        (format t "download-all~%")
        (cond ((string= (getf plist :download-type) "common")
               (download-common plist))
              ((string= (getf plist :download-type) "baidu")
               (download-baidu plist))
              ((string= (getf plist :download-type) "local")
               (download-local plist))
              ((string= (getf plist :download-type) "bt")
               (download-bt plist))
              ((not (getf plist :download-type))
               (error "download-type is nil")))
        (save-plist-file (update-plist-key plist
                                           :status
                                           "handle")
                         (get-task-save-path (getf plist :id))))
      plist))



(in-package :cl-user)

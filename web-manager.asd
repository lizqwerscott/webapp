;;;;The web asd

(defsystem web-manager
 :name "web"
 :version "0.0.0"
 :maintainer "lizqwer scott"
 :author "lizqwer scott"
 :licence "BSD sans advertising clause (see file COPYING for details)"
 :description "web-manager"
 :long-description "the download, zip and file manager."
 :components ((:file "package")
               (:module aria2
                      (:components (:file "marco" :depends-on "package")
                                   (:file "aria2" :depends-on "marco" "package")))
               (:file "main" :depends-on "package" aria2)))

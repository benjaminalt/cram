(defsystem cram-cloud-logger
  :depends-on (cram-language
               :cram-designators
               :cl-transforms
               :cl-transforms-stamped
               :cram-json-prolog
               :roslisp
               cram-utilities)
  :components
  ((:module "src"
    :components
    ((:file "package")
     (:file "utils" :depends-on ("package"))
     (:file "cloud-logger-client" :depends-on ("package" "utils"))
     (:file "cloud-logger-query-handler" :depends-on ("package" "cloud-logger-client" "utils"))
     (:file "knowrob-action-name-handler" :depends-on ("package" "utils"))
     (:file "action-parameter-handler" :depends-on ("package" "utils" "cloud-logger-query-handler"))
     (:file "utils-for-perform" :depends-on ("package" "cloud-logger-query-handler" "knowrob-action-name-handler" "action-parameter-handler" "utils"))))))

;;; Copyright (c) 2017, Gayane Kazhoyan <kazhoyan@cs.uni-bremen.de>
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Intelligent Autonomous Systems Group/
;;;       Technische Universitaet Muenchen nor the names of its contributors 
;;;       may be used to endorse or promote products derived from this software 
;;;       without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(defsystem cram-pr2-projection
  :author "Gayane Kazhoyan"
  :license "BSD"

  :depends-on (cram-projection
               cram-prolog
               cram-designators
               cram-utilities
               cram-bullet-reasoning
               cram-bullet-reasoning-belief-state ; for event updating before ik requests
               cram-tf
               cram-robot-interfaces    ; for ROBOT predicate and COMPUTE-IKS
               cl-transforms
               cl-transforms-stamped
               cl-tf
               cram-occasions-events
               cram-plan-occasions-events
               cram-pr2-description ; to get kinematic structure names
               cram-common-designators
               cram-common-failures
               cram-process-modules
               alexandria ; for CURRY in low-level perception
               roslisp-utilities ; for rosify-lisp-name
               moveit_msgs-msg
               moveit_msgs-srv
               pr2_arm_kinematics-msg
               pr2_arm_kinematics-srv)
  :components
  ((:module "src"
    :components
    ((:file "package")
     (:file "projection-clock" :depends-on ("package"))
     (:file "tf" :depends-on ("package"))
     (:file "ik" :depends-on ("package"))
     (:file "low-level" :depends-on ("package" "tf" "ik"))
     (:file "process-modules" :depends-on ("package" "low-level"))
     (:file "projection-environment" :depends-on ("package" "projection-clock" "tf"
                                                            "process-modules"))))))

;;;
;;; Copyright (c) 2018, Alina Hawkin <hawkin@cs.uni-bremen.de>
;;;                      Gayane Kazhoyan <kazhoyan@cs.uni-bremen.de>
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
;;;     * Neither the name of the Institute for Artificial Intelligence/
;;;       Universitaet Bremen nor the names of its contributors may be used to
;;;       endorse or promote products derived from this software without
;;;       specific prior written permission.
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

;;; initializes the episode data by connecting to OpenEase and loads the Episode data within OpenEase
;;; contains paths to the Episode data and SemanticMap
;;; which might need to be adjusted, if other episode data is to be loaded. 

;;; care to give the right rcg stamp
;;; rcg_c is for finding out the displacement
;;; rcg_f has the to date better grasps
;;; eval2 has best full set pick and place
;;; rcg_d different grasps
(in-package :kvr)

(defvar *kvr-enabled* t)

(defvar *episode-path*
  "/home/cram/ros_workspace/episode_data/episodes/Own-Episodes/set-clean-table/"
  "path of where the episode data is located")

(defun load-multiple-episodes (&optional namedir-list)
  ;;make a list of all directories of episodes and load them
  (unless namedir-list
    (setf namedir-list
          (mapcar #'directory-namestring
                  (uiop:subdirectories *episode-path*))))
  (mapcar #'(lambda (namedir)
              (u-load-episodes (concatenate 'string
                                            *episode-path* namedir "/Episodes/"))
              (owl-parse (concatenate 'string
                                      *episode-path* namedir "/SemanticMap.owl"))
              (connect-to-db "Own-Episodes_set-clean-table"))
          namedir-list))

(defun init-episode (&optional namedir-list)
  "Initializes the node and loads the episode data from knowrob via json_prolog.
The path of the episode files is set in the *episode-path* variable.
`namedir' is name of the episode file directory which is to be loaded.
The path is individual and therefore hardcoded one"
  (ros-info (kvr) "initializing the episode data and connecting to database...")
  ;; (start-ros-node "cram_knowrob_vr")
  (register-ros-package "knowrob_maps")
  (cpl:sleep 0.5)
  (register-ros-package "knowrob_common")
  (cpl:sleep 0.5)
  (register-ros-package "knowrob_robcog")
  (cpl:sleep 0.5)
  ;; below is stuff for running KVR on real robot with RS and KnowRob object stuff
  (when nil
    (register-ros-package "knowrob_srdl")
    (register-ros-package "knowrob_vis")
    (register-ros-package "knowrob_mongo")
    (register-ros-package "knowrob_objects")
    (register-ros-package "robosherlock_knowrob")
    (owl-parse "package://iai_semantic_maps/owl/kitchen.owl")
    (owl-parse "package://knowrob_srdl/owl/PR2.owl"))
  ;; end of "below stuff"
  (load-multiple-episodes namedir-list)
  (map-marker-init))

;;;;;;;;;;;;;;;;;;;;;;;; BULLET WORLD INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun spawn-semantic-map ()
  (setf btr:*mesh-path-whitelist* *mesh-path-whitelist-unreal-kitchen*)
  (prolog:prolog
   `(and (btr:bullet-world ?world)
         (assert (btr:object ?world :semantic-map :semantic-map-kitchen
                             ((,*semantic-map-offset-x*
                               ,*semantic-map-offset-y*
                               0)
                              (0 0 0 1)))))))

(defun spawn-urdf-items ()
  "Spawns all the objects the robot interacts with."
  (ros-info (kvr) "spawning objects for experiments...")
  ;; (btr-utils:kill-all-objects)
  ;; (btr:detach-all-objects (btr:get-robot-object))
  (btr:add-objects-to-mesh-list "cram_knowrob_vr")
  (let ((object-types '(:edeka-red-bowl :koelln-muesli-knusper-honig-nuss
                        :fork-blue-plastic :cup-eco-orange :weide-milch-small)))
    ;; spawn objects at default poses
    (let ((objects (mapcar (lambda (object-type)
                             (btr-utils:spawn-object
                              object-type object-type :color '(1 0 0)))
                           object-types)))
      objects))

  (btr-utils:spawn-object :axes :axes :color '(0 1 1))
  (btr-utils:spawn-object :axes :axes2 :color '(0 1 1))
  (btr-utils:spawn-object :axes :axes3 :color '(0 1 1)))

(defun spawn-semantic-items ()
  "Spawns all objects of the current Episode on their original position in the
semantic map kitchen."
  (btr:add-objects-to-mesh-list "cram_knowrob_vr")
  (let ((object-types '(:edeka-red-bowl :koelln-muesli-knusper-honig-nuss
                        :fork-blue-plastic :cup-eco-orange :weide-milch-small)))
    ;; spawn objects at default poses
    (let ((objects (mapcar (lambda (object-type)
                             (btr-utils:spawn-object
                              (intern (format nil "~a2" object-type) :keyword)
                              object-type
                              :color '(1 0 0)))
                           object-types)))
      objects)))

(defun init-location-costmap-parameters ()
  (def-fact-group costmap-metadata (costmap:costmap-size
                                    costmap:costmap-origin
                                    costmap:costmap-resolution
                                    costmap:orientation-samples
                                    costmap:orientation-sample-step)
    (<- (location-costmap:costmap-size 5 5))
    (<- (location-costmap:costmap-origin -2.5 -2.5))
    (<- (location-costmap:costmap-resolution 0.04))
    (<- (location-costmap:orientation-samples 2))
    (<- (location-costmap:orientation-sample-step 0.1))))

(defun init-full-simulation (&key namedir urdf-new-kitchen?)
   "Spawns all the objects which are necessary for the current
scenario (Meaning: Kitchen, Robot, Muesli, Milk, Cup, Bowl, Fork and 3 Axis
objects for debugging."
  ;; set the "unreal" prefix for the json_prolog node if we are running on a robot
  ;; and don't want to interfere with its KnowRob
  ;; we'll have our own KnowRob, with blackjack
  (setq json-prolog:*service-namespace* "/unreal/json_prolog")

  (roslisp-utilities:startup-ros)

  (when urdf-new-kitchen?
    (unless btr-belief:*kitchen-urdf*
      (let ((kitchen-urdf-string
              (roslisp:get-param btr-belief:*kitchen-parameter* nil)))
        (when kitchen-urdf-string
          (setf btr-belief:*kitchen-urdf*
                (cl-urdf:parse-urdf kitchen-urdf-string)))))
    (btr-belief:vary-kitchen-urdf))

  (coe:clear-belief)

  (when urdf-new-kitchen?
    (setf (btr:pose (btr:object btr:*current-bullet-world* (btr:get-robot-name)))
           (cram-tf:list->pose  '((-1 1.5 0) (0 0 0 1)))))

  (cram-bullet-reasoning:clear-costmap-vis-object)

  (spawn-urdf-items)

  (init-episode (or namedir
                    ;; (loop for i from 1 to 18 collecting (format nil "ep~a" i))
                    '(
                      "original1" "original2" "original3" "original4" "original5"
                      "original6" "original7" "original8" "original9" "original10"
                      "original11" "original12" "original13" "original14" "original15"
                      "original16" "original17" "original18" "original19" "original20"
                      "original21" "original22" "original23" "original24" "original25"
                      "original26" "original27"
                       ;; "exp1_t_1" "exp1_t_2" "exp1_t_3" "exp1_t_4" "exp1_t_5"
                       ;; "exp1_tc_1" "exp1_tc_2" "exp1_tc_3" "exp1_tc_4" "exp1_tc_5"
                       ;; "exp1_tr_1" "exp1_tr_2" "exp1_tr_3" "exp1_tr_4" "exp1_tr_5"
                      )))
  ;; (spawn-semantic-map)
  ;; (spawn-semantic-items)

  (init-location-costmap-parameters))


;;;; macros.lisp --- Macros provided by the architecture.builder-protocol system.
;;;;
;;;; Copyright (C) 2014, 2015 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:architecture.builder-protocol)

;; related to build protocol

(defmacro node ((builder kind &rest initargs &key &allow-other-keys)
                &body relations)
  "Use BUILDER to create a KIND, INITARGS node, relate it via RELATIONS.

   BUILDER, KIND and INITARGS are evaluated and passed to `make-node'.

   RELATIONS is a list of relation specifications of the form accepted
   by `make+finish-node+relations'.

   `finish-node' is called on the created node. The created node is
   returned.

   Example:

     (node (:operator :which '+)
       (* :operand (list left right)))"
  (flet ((wrap-in-list (spec)
           (destructuring-bind (arity relation right &rest args) spec
             `(list ',arity ,relation ,right ,@args))))
    `(make+finish-node+relations
      ,builder ,kind (list ,@initargs)
      (list ,@(mapcar #'wrap-in-list relations)))))

(defmacro node* ((kind &rest initargs &key &allow-other-keys) &body relations)
  "Like `node' but uses `*builder*' instead of accepting a builder
   parameter."
  `(node (*builder* ,kind ,@initargs)
     ,@relations))

;;; Helper for `with-builder' macro

(defun %expand-with-builder (spec body make-call)
  (destructuring-bind (builder-var-or-form
                       &optional
                       (builder-form nil builder-form-p))
      (ensure-list spec)
    (multiple-value-bind (builder-form builder-var var-p)
        (if builder-form-p
            (values builder-form builder-var-or-form t)
            (values builder-var-or-form (gensym)))
      (check-type builder-var symbol)
      `(flet ((with-builder-thunk (,builder-var)
                ,@(unless var-p `((declare (ignore ,builder-var))))
                ,@body))
         (declare (dynamic-extent #'with-builder-thunk))
         ,(funcall make-call builder-form '#'with-builder-thunk)))))

;;; `with-builder'

(defun call-with-builder (builder thunk)
  (finish builder (wrap (prepare builder) thunk)))

(defmacro with-builder (spec &body body)
  "Execute BODY with a builder binding according to SPEC.

   SPEC is either

     (BUILDER-VAR BUILDER-FORM)

       During the evaluation of BODY, BUILDER-VAR is bound to the
       result of evaluating BUILDER-FORM.

     (BUILDER-FORM)

       Before the evaluation of BODY, BUILDER-FORM is evaluated, but
       the constructed builder is only accessible through the
       `*builder*' special variable.

   Note that during the evaluation of BODY the special variable
   `*builder*' is usually bound to the builder constructed by
   BUILDER-FORM (depending on methods on `prepare' and `wrap')."
  (%expand-with-builder
   spec body
   (lambda (builder-form thunk-form)
     `(call-with-builder ,builder-form ,thunk-form))))
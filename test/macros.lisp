;;;; macros.lisp --- Unit tests for macros provided by the architecture.builder-protocol system.
;;;;
;;;; Copyright (C) 2014, 2015 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:architecture.builder-protocol.test)

;;; `with-builder'

(test with-builder.smoke.1
  "Smoke test for first syntax of the `with-builder' macro."

  (let ((result (with-builder ((make-instance
                                'preparable-finish-mock-builder))
                  (make-node *builder* :foo))))
    (is (equalp `(:finish ,(mock-node :foo :slots '(:prepared? t))) result))))

(test with-builder.smoke.2
  "Smoke test for second syntax of the `with-builder' macro."

  (let ((result (with-builder (builder (make-instance
                                        'preparable-finish-mock-builder))
                  (make-node builder :foo))))
    (is (equalp `(:finish ,(mock-node :foo :slots '(:prepared? t))) result))))

;;; `node[*]'

(test node.smoke
  "Smoke test for the `node' macro."

  (with-builder (builder (make-instance 'mock-builder))
    ;; Bare minimum.
    (is (equalp (mock-node :foo :finished? t)
                (node (builder :foo))))
    ;; Initargs.
    (is (equalp (mock-node :foo :slots '(:bar 1) :finished? t)
                (node (builder :foo :bar 1))))
    ;; Relation with ? cardinality.
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t))))
                           :finished? t)
                (node (builder :foo)
                  (? :bar (node (builder :baz))))))
    ;; Relation with 1 cardinality.
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t))))
                           :finished? t)
                (node (builder :foo)
                  (1 :bar (node (builder :baz))))))
    ;; Relation with * cardinality.
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t))
                                              (,(mock-node :baz :finished? t))))
                           :finished? t)
                (node (builder :foo)
                  (* :bar (list (node (builder :baz))
                                (node (builder :baz)))))))
    ;; Relation arguments
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t)
                                               :fez 1)))
                           :finished? t)
                (node (builder :foo)
                  (? :bar (node (builder :baz)) :fez 1))))))

(test node*.smoke
  "Smoke test for the `node*' macro."

  (with-builder ((make-instance 'mock-builder))
    ;; Bare minimum.
    (is (equalp (mock-node :foo :finished? t)
                (node* (:foo))))
    ;; Initargs.
    (is (equalp (mock-node :foo :slots '(:bar 1) :finished? t)
                (node* (:foo :bar 1))))
    ;; Relation with ? cardinality.
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t))))
                           :finished? t)
                (node* (:foo)
                  (? :bar (node* (:baz))))))
    ;; Relation with 1 cardinality.
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t))))
                           :finished? t)
                (node* (:foo)
                  (1 :bar (node* (:baz))))))
    ;; Relation with * cardinality.
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t))
                                              (,(mock-node :baz :finished? t))))
                           :finished? t)
                (node* (:foo)
                  (* :bar (list (node* (:baz))
                                (node* (:baz)))))))
    ;; Relation arguments
    (is (equalp (mock-node :foo
                           :relations `((:bar (,(mock-node :baz :finished? t)
                                                :fez 1)))
                           :finished? t)
                (node* (:foo)
                  (? :bar (node* (:baz)) :fez 1))))))
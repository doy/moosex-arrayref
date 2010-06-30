package MooseX::ArrayRef;
use Moose::Exporter;
# ABSTRACT: arrayref-based moose instances

Moose::Exporter->setup_import_methods(
    class_metaroles => {
        class    => ['MooseX::ArrayRef::Meta::Role::Class'],
        instance => ['MooseX::ArrayRef::Meta::Role::Instance'],
    },
);

1;

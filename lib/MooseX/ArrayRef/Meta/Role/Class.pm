package MooseX::ArrayRef::Meta::Role::Class;
use Moose::Role;

use List::MoreUtils qw(any);
use Data::OptList;

before superclasses => sub {
    my $self = shift;
    return if @_ == 0;

    my $supers = Data::OptList::mkopt(\@_);
    if (@$supers > 1 || any { scalar($_->meta->superclasses) > 1 } $self->linearized_isa) {
        $self->throw_error("Multiple inheritance is not supported in the inheritance hierarchy of arrayref-based instances");
    }

    my $super_meta = Class::MOP::Class->initialize($_[0]);
    if (!Moose::Util::does_role($super_meta->instance_metaclass, 'MooseX::ArrayRef::Meta::Role::Instance') && $super_meta->get_all_attributes) {
        $self->throw_error("Can't inherit from hashref-based Moose classes");
    }
};

before add_attribute => sub {
    my $self = shift;
    if ($self->subclasses) {
        $self->throw_error("Can't add attributes to a class with descendents");
    }
};

before rebless_instance => sub {
    shift->throw_error("Can't rebless arrayref-based instances");
};

before rebless_instance_back => sub {
    shift->throw_error("Can't rebless arrayref-based instances");
};

no Moose::Role;

1;

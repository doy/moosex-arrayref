package MooseX::ArrayRef::Meta::Role::Instance;
use Moose::Role;

my $NOT_EXISTS = \undef;

has slot_mapping => (
    traits  => ['Hash'],
    isa     => 'HashRef[Int]',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my @order = $self->_sorted_slots;
        return { map { $order[$_] => $_ } 0..$#order };
    },
    handles => {
        slot_index => 'get',
        num_slots  => 'count',
    },
);

sub _sorted_attributes {
    my $self = shift;
    return sort {
        my ($a_name, $b_name) = map { $_->associated_class->name } ($a, $b);
        $a_name eq $b_name
            ? $a->insertion_order <=> $b->insertion_order
            : $a_name->isa($b_name)
            ?  1
            : -1;

    } $self->get_all_attributes;
}

sub _sorted_slots {
    my $self = shift;
    return map { sort $_->slots } $self->_sorted_attributes;
}

sub create_instance {
    my $self = shift;
    bless [($NOT_EXISTS) x $self->num_slots], $self->_class_name;
}

sub clone_instance {
    my ($self, $instance) = @_;
    bless [ @$instance ], $self->_class_name;
}

sub get_slot_value {
    my ($self, $instance, $slot_name) = @_;
    my $val = $instance->[$self->slot_index($slot_name)];
    return $val unless ref($val);
    return undef if $val == $NOT_EXISTS;
    return $val;
}

sub set_slot_value {
    my ($self, $instance, $slot_name, $value) = @_;
    $instance->[$self->slot_index($slot_name)] = $value;
}

sub initialize_slot {
    my ($self, $instance, $slot_name) = @_;
    $instance->[$self->slot_index($slot_name)] = $NOT_EXISTS;
}

sub deinitialize_slot {
    my ($self, $instance, $slot_name) = @_;
    $instance->[$self->slot_index($slot_name)] = $NOT_EXISTS;
}

sub is_slot_initialized {
    my ($self, $instance, $slot_name) = @_;
    my $val = $instance->[$self->slot_index($slot_name)];
    !ref($val) || $val != $NOT_EXISTS;
}

sub weaken_slot_value {
    my ($self, $instance, $slot_name) = @_;
    weaken $instance->[$self->slot_index($slot_name)];
}

# TODO
sub is_inlinable { 0 }

no Moose::Role;

1;

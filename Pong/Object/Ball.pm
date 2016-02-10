package Pong::Object::Ball;

use Moo;
extends 'Pong::Object';
with qw(
	Pong::Component::Physics
	Pong::Component::Graphics
);

use Pong::Utils qw(round);

has '+size' => (default => sub { [ qw/1 1/ ] } );

sub move {
	my ($self, $game, $ball) = @_;

	my ($x, $y) = @{ $ball->position };
	my ($ew, $ns) = @{ $ball->direction };
	my $v = $ball->velocity;

	my ($nx, $ny) = ($x + $v, $y + $v);

	foreach my $obj ($game->objects) {
		next if $obj eq $ball;

		my ($ox, $oy) = @{ $obj->position };
		my ($sz_x, $sz_y) = @{ $obj->size };

		if (    ($nx >= $ox)
			and ($nx <= $ox + $sz_x)
			and ($ny >= $oy)
			and ($ny <= $oy + $sz_y)
		) {
#			printf "  Hitting a %s object!\n", ref $obj;
#			printf "    ox, oy: %d, %d\n", $ox, $oy;
#			printf "    sz_x, sz_y: %d, %d\n", $sz_x, $sz_y;
#			printf "    Old direction: %s%s\n", $ns, $ew;

			if ($ns eq 'N') {
				$ns = $ball->direction->[1] = 'S';
			}
			elsif ($ns eq 'S') {
				$ns = $ball->direction->[1] = 'N';
			}

#			printf "    New direction: %s%s\n", $ns, $ew;
		}
	}

	# Hitting a wall? Change direction.
	if (($y <= 0) and ($ns eq 'S')) {
		$ns = $ball->direction->[1] = 'N';
	}
	if (($y >= $game->size->[1]) and ($ns eq 'N')) {
		$ns = $ball->direction->[1] = 'S';
	}

	if (($x <= 0) and ($ew eq 'W')) {
		$ew = $ball->direction->[0] = 'E';
	}
	if (($x >= $game->size->[0]) and ($ew eq 'E')) {
		$ew = $ball->direction->[0] = 'W';
	}

	$y = $ball->position->[1] += $v if $ns eq 'N';
	$y = $ball->position->[1] -= $v if $ns eq 'S';
	$x = $ball->position->[0] += $v if $ew eq 'E';
	$x = $ball->position->[0] -= $v if $ew eq 'W';
}

sub draw {
	my ($self, $game, $ball, $win) = @_;

	my ($x, $y) = map round, @{ $ball->position };
	my ($w, $h) = @{ $ball->size };

	$win->addstr($y, $x * 1, "*" x ($w * 1));
	$win->refresh;
}

1;

package com.vehica.common.enums;

public enum BookingStatus {
    PENDING,
    CONFIRMED,
    PICKED_UP,
    COMPLETED,
    CANCELLED;

    public boolean canTransitionTo(BookingStatus nextStatus, UserRole actorRole) {
        if (this == COMPLETED || this == CANCELLED) {
            return false;
        }

        return switch (this) {
            case PENDING -> (nextStatus == CONFIRMED && actorRole == UserRole.ADMIN) ||
                            (nextStatus == CANCELLED); // USER or ADMIN can cancel PENDING
            case CONFIRMED -> (nextStatus == PICKED_UP && actorRole == UserRole.ADMIN) ||
                              (nextStatus == CANCELLED); // USER or ADMIN can cancel CONFIRMED
            case PICKED_UP -> nextStatus == COMPLETED && actorRole == UserRole.ADMIN;
            default -> false;
        };
    }
}

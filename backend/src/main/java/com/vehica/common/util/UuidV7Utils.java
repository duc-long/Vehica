package com.vehica.common.util;

import java.security.SecureRandom;
import java.util.UUID;

/**
 * ==============================================================================
 * VEHICA CAR RENTAL SYSTEM - UUID VERSION 7 (RFC 9562) UTILITY
 * ==============================================================================
 * UUIDv7 combines a 48-bit UNIX epoch timestamp (millisecond precision)
 * with 74 bits of cryptographically secure random entropy.
 * 
 * Benefits over UUIDv4:
 * 1. Monotonically increasing & time-ordered: dramatically optimizes B-Tree indexing in PostgreSQL / Supabase.
 * 2. High entropy: collision probability is virtually zero.
 * 3. Native compatibility: 128-bit standard UUID supported across all DBs & platforms.
 * ==============================================================================
 */
public final class UuidV7Utils {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private UuidV7Utils() {
        // Private constructor for utility class
    }

    /**
     * Generates an RFC 9562 compliant UUID version 7.
     *
     * @return time-ordered UUID version 7
     */
    public static UUID generateUuidV7() {
        return generateUuidV7(System.currentTimeMillis());
    }

    /**
     * Generates a UUIDv7 from a given epoch millisecond timestamp.
     *
     * @param epochMillis timestamp in milliseconds since Unix epoch
     * @return time-ordered UUID version 7
     */
    public static UUID generateUuidV7(long epochMillis) {
        // 48-bit timestamp in MSB bits 63..16
        long msb = (epochMillis & 0xFFFFFFFFFFFFL) << 16;

        // 4-bit version 7 in MSB bits 15..12: 0111
        msb |= (0x7L << 12);

        // 12-bit random value in MSB bits 11..0
        long randA = SECURE_RANDOM.nextInt(0x1000) & 0x0FFFL;
        msb |= randA;

        // LSB: 2-bit variant (10) in bits 63..62 + 62-bit random entropy
        long lsb = SECURE_RANDOM.nextLong();
        lsb = (lsb & 0x3FFFFFFFFFFFFFFFL) | 0x8000000000000000L;

        return new UUID(msb, lsb);
    }
}

package com.vehica.common.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class UuidV7UtilsTest {

    @Test
    @DisplayName("Should generate valid UUIDv7 with version 7 and variant 2")
    void testUuidV7Structure() {
        UUID uuid = UuidV7Utils.generateUuidV7();

        assertNotNull(uuid);
        assertEquals(7, uuid.version(), "UUID version must be 7");
        assertEquals(2, uuid.variant(), "UUID variant must be 2 (Leach-Salz / RFC 4122/9562)");
    }

    @Test
    @DisplayName("Should generate time-ordered sequential UUIDv7 values")
    void testUuidV7Ordering() throws InterruptedException {
        List<UUID> uuids = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            uuids.add(UuidV7Utils.generateUuidV7());
            Thread.sleep(2);
        }

        for (int i = 0; i < uuids.size() - 1; i++) {
            UUID current = uuids.get(i);
            UUID next = uuids.get(i + 1);

            assertEquals(7, current.version());
            assertEquals(2, current.variant());
            assertTrue(current.toString().compareTo(next.toString()) < 0,
                    "UUIDv7 should be sequentially ordered: " + current + " < " + next);
        }
    }
}

package com.vehica.common.keepalive;

import com.vehica.common.keepalive.dto.PingResponse;
import com.vehica.common.keepalive.service.SupabaseKeepAliveService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class PingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private SupabaseKeepAliveService keepAliveService;

    @Test
    void testKeepAliveServicePingDatabase() {
        PingResponse response = keepAliveService.pingDatabase();
        assertNotNull(response);
        assertEquals("UP", response.getStatus());
        assertEquals("CONNECTED", response.getDatabase());
        assertNotNull(response.getLatencyMs());
    }

    @Test
    void testGetPingEndpoint() throws Exception {
        mockMvc.perform(get("/api/v1/ping"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.status").value("UP"))
            .andExpect(jsonPath("$.data.database").value("CONNECTED"))
            .andExpect(jsonPath("$.data.message", containsString("Pong")));
    }

    @Test
    void testPostTriggerKeepAliveEndpoint() throws Exception {
        mockMvc.perform(post("/api/v1/ping/trigger"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.status").value("UP"))
            .andExpect(jsonPath("$.data.database").value("CONNECTED"));
    }
}

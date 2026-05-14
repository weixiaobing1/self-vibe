package com.mindflow.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger / OpenAPI 3.0 配置类
 */
@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI mindFlowOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("MindFlow AI - 学习助手接口文档")
                        .version("1.0.0")
                        .description("AI 驱动的学习记录、知识整理、面试出题与复习规划系统")
                        .contact(new Contact()
                                .name("MindFlow Team")));
    }
}
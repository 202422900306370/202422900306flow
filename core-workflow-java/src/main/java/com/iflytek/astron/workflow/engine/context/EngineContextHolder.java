package com.iflytek.astron.workflow.engine.context;

import com.alibaba.ttl.TransmittableThreadLocal;
import com.iflytek.astron.workflow.engine.node.callback.WorkflowMsgCallback;
import com.iflytek.astron.workflow.engine.util.FlowUtil;
import lombok.Data;

/**
 * 编排引擎执行上下文
 *
 * @author YiHui
 * @date 2025/12/1
 */
public class EngineContextHolder {
    private static TransmittableThreadLocal<EngineContext> contexts = new TransmittableThreadLocal<>();

    public static void set(EngineContext context) {
        contexts.set(context);
    }

    public static EngineContext get() {
        return contexts.get();
    }

    public static void remove() {
        contexts.remove();
    }


    public static EngineContext initContext(String flowId, String chatId, WorkflowMsgCallback workflowCallback) {
        EngineContext context = new EngineContext();
        context.setFlowId(flowId);
        context.setChatId(chatId);
        context.setCallback(workflowCallback);
        context.setSid(FlowUtil.genSid());
        set(context);
        return context;
    }

    @Data
    public static class EngineContext {
//        工作流标识，用于区分不同的工作流实例
        private String flowId;
//        会话标识，多次会话归为同一会话，用于多轮对话场景的上下文关联
        private String chatId;
//        回调接口实例，引擎执行过程中回调信息给调用者
        private WorkflowMsgCallback callback;
//        sid (TraceId) 用于链路追踪，方便日志关联和问题排查
        private String sid;
    }
}

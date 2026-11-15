{
  # PR-Agent：以 GitHub App 形式审查 pull request 的服务。
  #
  # 容器监听 127.0.0.1:3000，公网入口由 Tailscale Funnel 提供。
  # Funnel 是单次交互式操作，启用后由 tailscaled 持久化：
  #   sudo tailscale funnel --bg 3000
  # webhook URL 为 https://qaaxaapserver-1.taila7a836.ts.net/api/v1/github_webhooks
  #
  # 只响应 PR 评论里的 /review 等命令，不自动审查新 PR：
  #   handle_pr_actions 与 pr_commands 均为空。
  #
  # secrets 不放进 nix store，手动维护 /srv/pr-agent/.secrets.toml：
  #   [github] app_id / private_key / webhook_secret
  #   [deepseek] key
  # 改完后 systemctl restart docker-pr-agent。

  users.users.pr-agent = {
    isSystemUser = true;
    uid = 10001;
    group = "pr-agent";
  };
  users.groups.pr-agent.gid = 10001;

  systemd.tmpfiles.rules = [
    "d /srv/pr-agent 0700 pr-agent pr-agent -"
    "f /srv/pr-agent/.secrets.toml 0600 pr-agent pr-agent -"
  ];

  virtualisation.oci-containers = {
    backend = "docker";

    containers.pr-agent = {
      image = "pragent/pr-agent:0.50.0-github_app";
      autoStart = true;
      ports = [ "127.0.0.1:3000:3000" ];
      volumes = [
        "/srv/pr-agent/.secrets.toml:/app/pr_agent/settings/.secrets.toml:ro"
      ];
      environment = {
        PORT = "3000";
        GUNICORN_WORKERS = "2";
        # DeepSeek 当前 flash 模型：deepseek-flash（V4.1-Flash-1017）。
        CONFIG__MODEL = "deepseek/deepseek-flash";
        CONFIG__FALLBACK_MODELS = "[]";
        CONFIG__CUSTOM_MODEL_MAX_TOKENS = "1000000";
        # flash 上下文 1M，放宽 PR-Agent 的 prompt 预算，避免大 PR 裁剪 diff。
        CONFIG__MAX_MODEL_TOKENS = "512000";
        GITHUB__DEPLOYMENT_TYPE = "app";
        # 关闭 PR opened 等事件的自动命令，只保留评论触发的 /review。
        GITHUB_APP__HANDLE_PR_ACTIONS = "[]";
        GITHUB_APP__PR_COMMANDS = "[]";
      };
    };
  };
}

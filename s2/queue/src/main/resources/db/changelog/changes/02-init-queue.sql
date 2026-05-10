-- liquibase formatted sql
-- changeset author:queue-setup

CREATE TABLE tasks (
    id           BIGSERIAL PRIMARY KEY,
    payload      JSONB NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'Ready',
    priority     INT NOT NULL DEFAULT 1,
    attempts     INT NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    worker_id    VARCHAR(50)
) WITH (
    autovacuum_vacuum_scale_factor = 0.02,
    -- какая доля таблицы должна быть из мертвых строк чтобы запустился autovacuum
    autovacuum_analyze_scale_factor = 0.01
    -- доля измененных строк необходимая для запуска обновления статистика планировщика
    );

CREATE INDEX idx_tasks_poll ON tasks (priority DESC, scheduled_at ASC) WHERE status = 'Ready';
CREATE INDEX idx_tasks_created_ready ON tasks (created_at) WHERE status = 'Ready';

-- changeset author:queue-setup-function splitStatements:false
CREATE OR REPLACE FUNCTION notify_new_task()
RETURNS TRIGGER AS
$$
BEGIN
    PERFORM pg_notify('new_tasks_channel', NEW.id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- changeset author:queue-setup-trigger
CREATE TRIGGER on_task_insert
AFTER INSERT ON tasks
FOR EACH ROW
EXECUTE PROCEDURE notify_new_task();
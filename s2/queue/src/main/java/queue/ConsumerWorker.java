package queue;

import jakarta.annotation.PostConstruct;
import org.postgresql.PGConnection;
import org.postgresql.PGNotification;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Random;
import java.util.UUID;

@Service
@Profile("consumer")
public class ConsumerWorker {

    private final TaskService taskService;
    private final DataSource dataSource;
    private final String workerId;
    private final Random random = new Random();

    public ConsumerWorker(TaskService taskService, DataSource dataSource) {
        this.taskService = taskService;
        this.dataSource = dataSource;
        this.workerId = "worker-" + UUID.randomUUID().toString().substring(0, 6);
    }

    @PostConstruct
    public void initListener() {
        Thread listenerThread = new Thread(() -> {
            try (Connection conn = dataSource.getConnection()) {
                PGConnection pgConn = conn.unwrap(PGConnection.class);
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("LISTEN new_tasks_channel");
                }

                System.out.println(workerId + " started. Listening for tasks...");

                processAvailableTasks();

                while (!Thread.currentThread().isInterrupted()) {
                    PGNotification[] notifications = pgConn.getNotifications(5000);

                    if (notifications != null && notifications.length > 0) {
                        processAvailableTasks();
                    } else {
                        processAvailableTasks();
                    }
                }
            } catch (Exception e) {
                System.err.println(workerId + " listener error: " + e.getMessage());
            }
        });
        listenerThread.start();
    }

    private void processAvailableTasks() {
        Task task;
        while ((task = taskService.grabTask(workerId)) != null) {
            try {
                Thread.sleep(random.nextInt(50) + 50);

                boolean success = random.nextInt(100) >= 10;

                taskService.finalizeTask(task, success);
                System.out.println(workerId + " processed task " + task.getId() + " - Success: " + success);

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            } catch (Exception e) {
                taskService.finalizeTask(task, false);
            }
        }
    }
}
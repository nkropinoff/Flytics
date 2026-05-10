package queue;

import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.persistence.EntityManager;
import queue.TaskRepository;

import java.util.Random;

@Service
@Profile("producer")
public class ProducerService {

    private final TaskRepository taskRepository;
    private final EntityManager entityManager;
    private final Random random = new Random();

    public ProducerService(TaskRepository taskRepository, EntityManager entityManager) {
        this.taskRepository = taskRepository;
        this.entityManager = entityManager;
    }

    @Scheduled(fixedDelay = 5)
    @Transactional
    public void generateEvent() {
        entityManager.createNativeQuery(
                        "INSERT INTO booking (client_id, booking_date, total_cost, status_id) " +
                                "VALUES (1, now(), :cost, 1)")
                .setParameter("cost", 5000 + random.nextInt(20000))
                .executeUpdate();

        Task task = new Task();
        task.setPayload("{\"action\": \"ISSUE_TICKET\"}");

        task.setPriority(random.nextInt(100) < 20 ? 10 : 1);
        taskRepository.save(task);
    }
}
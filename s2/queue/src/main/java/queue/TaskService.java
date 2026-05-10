package queue;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.OffsetDateTime;
import java.util.Optional;

@Service
public class TaskService {

    private final TaskRepository repository;

    public TaskService(TaskRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public Task grabTask(String workerId) {
        Optional<Task> optTask = repository.findReadyTaskForUpdate();
        if (optTask.isPresent()) {
            Task task = optTask.get();
            task.setStatus("Running");
            task.setWorkerId(workerId);
            task.setUpdatedAt(OffsetDateTime.now());
            return repository.save(task);
        }
        return null;
    }

    @Transactional
    public void finalizeTask(Task task, boolean success) {
        if (success) {
            task.setStatus("Completed");
        } else {
            task.setAttempts(task.getAttempts() + 1);
            if (task.getAttempts() >= 3) {
                task.setStatus("Failed");
            } else {
                task.setStatus("Ready");
                long backoffMinutes = 5L * (1L << (task.getAttempts() - 1));
                task.setScheduledAt(OffsetDateTime.now().plusMinutes(backoffMinutes));
            }
        }
        task.setUpdatedAt(OffsetDateTime.now());
        repository.save(task);
    }
}
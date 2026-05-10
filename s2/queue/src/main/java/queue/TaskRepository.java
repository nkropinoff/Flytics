package queue;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface TaskRepository extends JpaRepository<Task, Long> {

    @Query(value = """
            SELECT * FROM tasks
            WHERE status = 'Ready' AND scheduled_at <= now() 
            ORDER BY priority DESC, scheduled_at ASC 
            FOR UPDATE SKIP LOCKED 
            LIMIT 1
            """, nativeQuery = true)
    Optional<Task> findReadyTaskForUpdate();
}
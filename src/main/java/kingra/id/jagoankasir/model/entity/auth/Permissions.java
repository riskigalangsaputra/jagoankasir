package kingra.id.jagoankasir.model.entity.auth;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Permissions {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String permissionName;

    @Column(nullable = false)
    private String description;

    @Column(nullable = false)
    private boolean isActive;
}

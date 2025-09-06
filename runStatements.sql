--Listado de Clientes que mas pagan por edificio
SELECT e.id_edificio,
    e.nombre_estacionamiento AS edificio,
    c.id_cliente,
    c.nombre_cliente AS cliente,
    SUM(p.monto) AS gasto_total
FROM Cliente c
JOIN Cliente_vehiculo cv ON c.id_cliente = cv.id_cliente
JOIN Contrato ct ON cv.id_cliveh = ct.id_cliveh
JOIN Pago p ON ct.id_contrato = p.id_contrato
JOIN Edificio_estacionamiento e ON ct.id_edificio = e.id_edificio
GROUP BY e.id_edificio, c.id_cliente, c.nombre_cliente, e.nombre_estacionamiento
HAVING SUM(p.monto) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(p2.monto) AS total
        FROM Cliente c2
        JOIN Cliente_vehiculo cv2 ON c2.id_cliente = cv2.id_cliente
        JOIN Contrato ct2 ON cv2.id_cliveh = ct2.id_cliveh
        JOIN Pago p2 ON ct2.id_contrato = p2.id_contrato
        WHERE ct2.id_edificio = e.id_edificio
        GROUP BY c2.id_cliente
    )
)
ORDER BY e.id_edificio;
--Modelo de auto menos recurrente por edificio
SELECT 
    e.nombre_estacionamiento AS edificio,
    m.marca,
    m.nombre_modelo,
    COUNT(*) AS frecuencia_en_estacionamiento
FROM Edificio_estacionamiento e
JOIN Contrato ct ON e.id_edificio = ct.id_edificio
JOIN Cliente_vehiculo cv ON ct.id_cliveh = cv.id_cliveh
JOIN Vehiculo v ON cv.id_vehiculo = v.id_vehiculo
JOIN Modelo m ON v.id_modelo = m.id_modelo
GROUP BY e.id_edificio, m.id_modelo, m.marca, m.nombre_modelo
HAVING COUNT(*) = (
    SELECT MIN(cantidad)
    FROM (
        SELECT COUNT(*) AS cantidad
        FROM Contrato ct2
        JOIN Cliente_vehiculo cv2 ON ct2.id_cliveh = cv2.id_cliveh
        JOIN Vehiculo v2 ON cv2.id_vehiculo = v2.id_vehiculo
        WHERE ct2.id_edificio = e.id_edificio
        GROUP BY v2.id_modelo
    )
)
ORDER BY e.id_edificio, frecuencia_en_estacionamiento;
--3. Empleados con mayor y menor sueldo por edificio
SELECT e.id_edificio,
    ed.nombre_estacionamiento AS edificio,
    e.id_empleado,
    e.nombre AS empleado,
    SUM(s.monto) AS sueldo_total,
    'Mayor' AS tipo_sueldo
FROM Empleado e
JOIN Sueldo s ON e.id_empleado = s.id_empleado
JOIN Edificio_estacionamiento ed ON e.id_edificio = ed.id_edificio
GROUP BY e.id_edificio, ed.nombre_estacionamiento, e.id_empleado, e.nombre
HAVING SUM(s.monto) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(s2.monto) AS total
        FROM Empleado e2
        JOIN Sueldo s2 ON e2.id_empleado = s2.id_empleado
        WHERE e2.id_edificio = e.id_edificio
        GROUP BY e2.id_empleado
    ) AS max_sueldo
)

UNION ALL

SELECT e.id_edificio,
    ed.nombre_estacionamiento AS edificio,
    e.id_empleado,
    e.nombre AS empleado,
    SUM(s.monto) AS sueldo_total,
    'Menor' AS tipo_sueldo
FROM Empleado e
JOIN Sueldo s ON e.id_empleado = s.id_empleado
JOIN Edificio_estacionamiento ed ON e.id_edificio = ed.id_edificio
GROUP BY e.id_edificio, ed.nombre_estacionamiento, e.id_empleado, e.nombre
HAVING SUM(s.monto) = (
    SELECT MIN(total)
    FROM (
        SELECT SUM(s2.monto) AS total
        FROM Empleado e2
        JOIN Sueldo s2 ON e2.id_empleado = s2.id_empleado
        WHERE e2.id_edificio = e.id_edificio
        GROUP BY e2.id_empleado
    ) AS min_sueldo
)

ORDER BY id_edificio, tipo_sueldo DESC;
--4. Lista de comunas con la cantidad de clientes
SELECT com.id_comuna, com.nombre_comuna AS comuna,
    COUNT(c.id_cliente) AS total_clientes
FROM Comuna com
LEFT JOIN Cliente c ON com.id_comuna = c.id_comuna
GROUP BY com.id_comuna, com.nombre_comuna
ORDER BY total_clientes DESC;
--5. Edificios con más lugares disponibles
SELECT e.id_edificio,
    e.nombre_estacionamiento AS edificio,
    COUNT(l.id_lugar) AS lugares_disponibles
FROM Edificio_estacionamiento e
JOIN Lugar l ON e.id_edificio = l.id_edificio
WHERE l.estado = 'disponible'
GROUP BY e.id_edificio, e.nombre_estacionamiento
HAVING COUNT(l.id_lugar) = (
    SELECT MAX(cantidad)
    FROM (
        SELECT COUNT(l2.id_lugar) AS cantidad
        FROM Edificio_estacionamiento e2
        JOIN Lugar l2 ON e2.id_edificio = l2.id_edificio
        WHERE l2.estado = 'disponible'
        GROUP BY e2.id_edificio
    )
)
ORDER BY e.id_edificio;
--6. Edificios con menos lugares disponibles
/* SUPUESTO: consideramos que como es la "menor cantidad"
sugiere que al menos debe de existir un lugar, por lo que los estacionaminetos
sin lugar disponible no son considerados */
SELECT e.id_edificio,
    e.nombre_estacionamiento AS edificio,
    COUNT(l.id_lugar) AS lugares_disponibles
FROM Edificio_estacionamiento e
JOIN Lugar l ON e.id_edificio = l.id_edificio
WHERE l.estado = 'disponible'
GROUP BY e.id_edificio, e.nombre_estacionamiento
HAVING COUNT(l.id_lugar) = (
    SELECT MIN(cantidad)
    FROM (
        SELECT COUNT(l2.id_lugar) AS cantidad
        FROM Edificio_estacionamiento e2
        JOIN Lugar l2 ON e2.id_edificio = l2.id_edificio
        WHERE l2.estado = 'disponible'
        GROUP BY e2.id_edificio
    )
)
ORDER BY e.id_edificio;
--7.Clientes con más autos por edificio
SELECT
    e.nombre_estacionamiento AS edificio,
    c.nombre_cliente AS cliente,
    COUNT(DISTINCT v.id_vehiculo) AS cantidad_autos
FROM Cliente c
JOIN Cliente_vehiculo cv ON c.id_cliente = cv.id_cliente
JOIN Vehiculo v ON cv.id_vehiculo = v.id_vehiculo
JOIN Contrato ct ON cv.id_cliveh = ct.id_cliveh
JOIN Edificio_estacionamiento e ON ct.id_edificio = e.id_edificio
GROUP BY e.id_edificio, e.nombre_estacionamiento, c.id_cliente, c.nombre_cliente
HAVING COUNT(DISTINCT v.id_vehiculo) = (
    SELECT MAX(cantidad)
    FROM (
        SELECT COUNT(DISTINCT v2.id_vehiculo) AS cantidad
        FROM Cliente_vehiculo cv2
        JOIN Vehiculo v2 ON cv2.id_vehiculo = v2.id_vehiculo
        JOIN Contrato ct2 ON cv2.id_cliveh = ct2.id_cliveh
        WHERE ct2.id_edificio = e.id_edificio
        GROUP BY cv2.id_cliente
    ) AS subconsulta
)
ORDER BY e.id_edificio;
--8. Lugar más usado por edificio
SELECT e.id_edificio,
    e.nombre_estacionamiento AS edificio,
    l.id_lugar,
    l.numero_lugar,
    COUNT(*) AS veces_usado
FROM Edificio_estacionamiento e
JOIN Lugar l ON e.id_edificio = l.id_edificio
JOIN Lugar_cliveh lc ON l.id_lugar = lc.id_lugar
GROUP BY e.id_edificio, e.nombre_estacionamiento, l.id_lugar, l.numero_lugar
HAVING COUNT(*) = (
    SELECT MAX(uso)
    FROM (
        SELECT COUNT(*) AS uso
        FROM Lugar l2
        JOIN Lugar_cliveh lc2 ON l2.id_lugar = lc2.id_lugar
        WHERE l2.id_edificio = e.id_edificio
        GROUP BY l2.id_lugar
    ) AS subconsulta
)
ORDER BY e.id_edificio, l.numero_lugar;
--9.Edificio con más empleados
SELECT e.id_edificio,
    e.nombre_estacionamiento AS edificio,
    COUNT(emp.id_empleado) AS total_empleados
FROM Edificio_estacionamiento e
JOIN Empleado emp ON e.id_edificio = emp.id_edificio
GROUP BY e.id_edificio, e.nombre_estacionamiento
HAVING COUNT(emp.id_empleado) = (
    SELECT MAX(cantidad)
    FROM (
        SELECT COUNT(emp2.id_empleado) AS cantidad
        FROM Edificio_estacionamiento e2
        JOIN Empleado emp2 ON e2.id_edificio = emp2.id_edificio
        GROUP BY e2.id_edificio
    )
)
ORDER BY e.id_edificio;
--10. Lista de sueldos por tipo de empleado y edificio (con comuna)
SELECT 
    ed.nombre_estacionamiento AS edificio,
    co.nombre_comuna AS comuna,
    e.cargo AS tipo_empleado,
    s.monto AS sueldo
FROM Sueldo s
JOIN Empleado e ON s.id_empleado = e.id_empleado
JOIN Edificio_estacionamiento ed ON e.id_edificio = ed.id_edificio
JOIN Comuna co ON ed.id_comuna = co.id_comuna
ORDER BY ed.nombre_estacionamiento, e.cargo;



//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);

    logic [width - 1:0] shift_reg;
    logic [3:0] bit_count; // Счетчик битов (достаточно 4 бит для подсчета до 16)

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 0;
            bit_count <= 0;
            parallel_valid <= 0;
        end else begin
            if (serial_valid) begin
                // Сдвиг данных и добавление нового бита
                shift_reg <= {shift_reg[width - 2:0], serial_data};
                bit_count <= bit_count + 1;

                // Проверяем, накоплено ли уже width бит
                if (bit_count == width - 1) begin
                    parallel_valid <= 1; // Устанавливаем сигнал о готовности
                    parallel_data <= shift_reg; // Выдаем накопленные данные
                end
            end
            
            // После того, как данные выданы, 
            // сбрасываем valid сигнал и убираем данные
            if (parallel_valid) begin
                parallel_valid <= 0; // Сбрасываем сигнал готовности
                bit_count <= 0; // Сбрасываем счетчик
            end
        end
    end

endmodule


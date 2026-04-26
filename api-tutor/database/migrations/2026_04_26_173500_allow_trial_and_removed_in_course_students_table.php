<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE course_students MODIFY COLUMN status ENUM('pending', 'approved', 'rejected', 'removed') DEFAULT 'pending'");
        DB::statement("ALTER TABLE course_students MODIFY COLUMN payment_status ENUM('trial', 'paid', 'due', 'grace_period', 'overdue') DEFAULT 'paid'");
    }

    public function down(): void
    {
        DB::table('course_students')->where('status', 'removed')->update(['status' => 'rejected']);
        DB::table('course_students')->where('payment_status', 'trial')->update(['payment_status' => 'paid']);

        DB::statement("ALTER TABLE course_students MODIFY COLUMN status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending'");
        DB::statement("ALTER TABLE course_students MODIFY COLUMN payment_status ENUM('paid', 'due', 'grace_period', 'overdue') DEFAULT 'paid'");
    }
};

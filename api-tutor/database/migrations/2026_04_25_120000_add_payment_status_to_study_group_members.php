<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('study_group_members', function (Blueprint $table) {
            if (!Schema::hasColumn('study_group_members', 'payment_status')) {
                $table->enum('payment_status', ['pending', 'paid'])->default('pending')->after('status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('study_group_members', function (Blueprint $table) {
            $table->dropColumn('payment_status');
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('tutor_requests', function (Blueprint $table) {
            $table->enum('request_type', ['1-1', 'group'])->default('1-1')->after('mode');
            $table->boolean('is_tutor_created')->default(false)->after('request_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tutor_requests', function (Blueprint $table) {
            $table->dropColumn(['request_type', 'is_tutor_created']);
        });
    }
};

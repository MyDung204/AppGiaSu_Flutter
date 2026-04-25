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
        Schema::table('quizzes', function (Blueprint $table) {
            $table->foreignId('student_id')->nullable()->after('course_id')->constrained('users')->onDelete('set null');
        });

        Schema::table('tutor_materials', function (Blueprint $table) {
            $table->foreignId('course_id')->nullable()->after('tutor_id')->constrained('courses')->onDelete('set null');
            $table->foreignId('student_id')->nullable()->after('course_id')->constrained('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->dropColumn('student_id');
        });

        Schema::table('tutor_materials', function (Blueprint $table) {
            $table->dropForeign(['course_id']);
            $table->dropForeign(['student_id']);
            $table->dropColumn(['course_id', 'student_id']);
        });
    }
};
